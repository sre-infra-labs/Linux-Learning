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

## SELinux - commands

```bash

# find out selinux mode
getenforce

# enable permissible mode
setenforce 0

# enable forcing mode
setenforce 1

# find selinux port contexts
semanage port -l

# find selinux file contexts
semanage fcontext -l

# help on semanage. Goto "SEE ALSO" section to find other releated man documents
man semanage
man semanage-port
man semanage-boolean
man semanage-fcontext

# get list of all booleans available in currently running policies
getsebool -a

```

## Example 01 - SELinux context permissions for httpd Files
```bash
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

# Add a user-defined file context labeling rule. File contexts define what files confined domains are allowed to access:
semanage fcontext -a -t httpd_sys_content_t "/data/student(/.*)?"
semanage fcontext -l | grep student
restorecon -R /data/student/ 

```


## Example 02 - SELinux permissions for Port

```bash
# Check current SSH Port
grep -i 'port' /etc/ssh/sshd_config
grep -i 'port' /etc/ssh/sshd_config | sed -e 's/#Port 22/Port 2022/'

# Update ssh port to 2022 in /etc/ssh/sshd_config
sed -i -e 's/#Port 22/Port 2022/' /etc/ssh/sshd_config

# Restart sshd service. Fails to restart
systemctl restart sshd

    Job for sshd.service failed because the control process exited with error code.
    See "systemctl status sshd.service" and "journalctl -xeu sshd.service" for details.

# Check log
tail /var/log/messages | bat
    Sep 24 07:55:25 centos setroubleshoot[56825]: SELinux is preventing /usr/sbin/sshd from name_bind access on the tcp_socket port
        │  2022. For complete SELinux messages run: sealert -l b426a533-f6e8-4f4c-850f-203631b658a2
      7 │ Sep 24 07:55:25 centos setroubleshoot[56825]: SELinux is preventing /usr/sbin/sshd from name_bind access on the tcp_socket port
        │  2022.#012#012*****  Plugin bind_ports (92.2 confidence) suggests   ************************#012#012If you want to allow /usr/s
        │ bin/sshd to bind to network port 2022#012Then you need to modify the port type.#012Do#012# semanage port -a -t PORT_TYPE -p tcp
        │  2022#012    where PORT_TYPE is one of the following: ssh_port_t, vnc_port_t, xserver_port_t.#012#012*****  Plugin catchall_boo
        │ lean (7.83 confidence) suggests   ******************#012#012If you want to allow nis to enabled#012Then you must tell SELinux a
        │ bout this by enabling the 'nis_enabled' boolean.#012#012Do#012setsebool -P nis_enabled 1#012#012*****  Plugin catchall (1.41 co
        │ nfidence) suggests   **************************#012#012If you believe that sshd should be allowed name_bind access on the port 
        │ 2022 tcp_socket by default.#012Then #012    You should report this as a bug.#012#012    If you are certain this access is legit
        │ imate and not an intrusion attempt, you#012    can generate a local policy module to allow it.#012    Custom policy modules are
        │  not supported as they may weaken the system policy and expose the system to security vulnerabilities.#012    #012Do#012# ausea
        │ rch -c 'sshd' --raw | audit2allow -M my-sshd#012# semodule -X 300 -i my-sshd.pp#012

# find out selinux mode
getenforce

# Try to see if error comes up after disabling SELinux
setenforce 0
systemctl restart sshd
systemctl status sshd
    <<'COMMAND_OUTPUT'
    root@centos:~# systemctl status sshd
    ● sshd.service - OpenSSH server daemon
        Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)
        Active: active (running) since Thu 2026-09-24 07:58:06 IST; 7s ago
    Invocation: df05614f022a4bc0a8c92b18de87a02c
          Docs: man:sshd(8)
                man:sshd_config(5)
      Main PID: 57009 (sshd)
          Tasks: 1 (limit: 29437)
        Memory: 1.2M (peak: 1.4M)
            CPU: 16ms
        CGroup: /system.slice/sshd.service
                └─57009 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

    Sep 24 07:58:05 centos systemd[1]: Starting sshd.service - OpenSSH server daemon...
    Sep 24 07:58:06 centos sshd[57009]: Server listening on 0.0.0.0 port 2022.
    Sep 24 07:58:06 centos sshd[57009]: Server listening on :: port 2022.
    Sep 24 07:58:06 centos systemd[1]: Started sshd.service - OpenSSH server daemon.
COMMAND_OUTPUT

# List all SELinux Port Object Types
semanage port -l | grep -i ssh

    root@centos:~# semanage port -l | grep -i ssh
    ssh_port_t                     tcp      22

# Notice that port 2022 is not in bind type in above ssh port object

# Add 2022 as port for ssh_port_t type
semanage port -a -t ssh_port_t -p tcp 2022

# List ssh port type again
semanage port -l | grep -i ssh

    root@centos:~# semanage port -l | grep -i ssh
    ssh_port_t                     tcp      2022, 22

# enable forcing mode
setenforce 1

# restart the sshd service
systemctl restart sshd
systemctl status sshd

```

## Example 03 - SELinux boolean

```bash
# get list of all booleans available in currently running policies
getsebool -a

# Enable a boolean available for httpd that allows user home directory access
getsebool -a | grep -i httpd | grep -i home
    root@centos:~# getsebool -a | grep -i httpd | grep -i home
    httpd_enable_homedirs --> off

setsebool httpd_enable_homedirs=1

getsebool -a | grep -i httpd | grep -i home
    root@centos:~# getsebool -a | grep -i httpd | grep -i home
    httpd_enable_homedirs --> on

# Enable boolean "Permanently"
setsebool -P httpd_enable_homedirs=1


```



