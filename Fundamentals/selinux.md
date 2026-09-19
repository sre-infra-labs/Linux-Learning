# SELinux

Selinux is an additional security layer that controls what a linux process is allowed to access--even when normal
Linux permissions say it is allowed.

SELinux = Security-Enhanced Linux

It implements Mandatory Access Control (MAC) on Linux.

Traditional Linux security mainly uses:

- User
- Group
- File permissions
- rwx

DAC - Discretionary Access Control - Here owner can decide who gets access.

Example:

`-rw-r-----  dbuser dba  database.conf`

If a process runs as dbuser, normal Linux permissions may allow it to read the file.

SELinux adds another question:

> Is this process's security policy allowed to access this type of file?

SELinux imposes centrally defined rules using MAC.

Think of SELinux as security labels.

SELinux assigns a security context to processes and files.

ls -Z
    `-rw-r--r--. root root system_u:object_r:httpd_config_t:s0 httpd.conf`

`ps -eZ | grep httpd`
    `system_u:system_r:httpd_t:s0`

SELinux context has four components -

```
system_u : object_r : httpd_config_t : s0
   │          │             │          │
   │          │             │          └─── MLS/MCS level
   │          │             └────────────── SELinux type
   │          └──────────────────────────── SELinux role
   └─────────────────────────────────────── SELinux user
```

## Troubleshooting

Check audit log & check for AVC denials:

```
# rhel
tail /var/log/messages
# ubuntu
tail /var/log/syslog

grep AVC /var/log/audit/audit.log

```

A typical log entry like -

```
avc: denied { read }
for pid=1234
comm="httpd"
scontext=system_u:system_r:httpd_t:s0
tcontext=system_u:object_r:default_t:s0
tclass=file
```

This tells -

```
Process:
httpd_t

Tried to access:
default_t

Operation:
read

Result:
denied
```

# check selinux context for httpd directory
ls -lZ /var/wwww/html

# restore correct context
restorecon /var/www/html/index.html

# copy vs move? for SELinux
Copy uses selinux content of target whereas Move keeps selinux context of source.


cd ~
echo "This is my first html page" > index.html

pwd
ls -lZ

# this copy method based creation of file adopts target selinux context
copy index.html /var/www/html/index.html

# this move method based creation of file adopts source selinux context
mv index.html /var/www/html/index.html

# change context of file/folder onetime
chcon -t httpd_sys_content_t /data/student/datafile

# dd a user-defined file context labeling rule. File contexts define what files confined domains are allowed to access:
semanage fcontext -a -t httpd_sys_content_t "/data/student(/.*)?"
semanage fcontext -l | grep student
restorecon -R /data/student/ 


# find out selinux mode
getenforce

# enable permissible mode
setenforce 0

# enable forcing mode
setenforce 1

