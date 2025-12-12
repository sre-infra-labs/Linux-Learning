:<<'COMMENTS'

Understanding Basic Linux Permissions
--------------------------------------

+-------------+-----------------------+-----------------------+
| Permission  | File                  | Directory            |
+-------------+-----------------------+-----------------------+
| Read (r)    | View contents         | List contents (ls)   |
|             | (cat, less)           |                      |
+-------------+-----------------------+-----------------------+
| Write (w)   | Modify contents       | Add/Delete files     |
|             | (edit, truncate)      | (create/remove)      |
+-------------+-----------------------+-----------------------+
| Execute (x) | Run as a program      | Access directory     |
|             | (execute binary)      | (cd into directory)  |
+-------------+-----------------------+-----------------------+

-> Basic Permissions can be set to files and directories
-> Octal Values: Read (4), Write (2), Execute (1)
-> "chmod" command is used to change file permissions.


Managing File Ownership
-----------------------

-> To manager permissions, file ownership is managed first
-> By default, the user who creates a files becomes user-owner, the primary group of that user becomes group-owner, and everybody else is the others owner(ugo).
-> Standard Linux permissions allow for one user-owner, one group-owner for each file.
-> Use "chown" to change user ownership
    -> chown anna myfile
    -> chown anna:sales /data/sales
-> Use "chgrp" to change group ownership
    -> chgrp sales /data/sales
    -> chgrp -R sales /data/sales


Managing File Permissions
-------------------------

-> "chmod" is used to manage file permissions
-> In absolute mode, it sets permissions to ugo:
    -> chmod 750 myfile
-> Alternatively, relative mode can be used:
    -> chmod +x myfile
    -> chmod o-x myfile
-> Best practice: use absolute mode for full control, use relative mode for quick changes.


COMMENTS

# create direct, and check its user owner & group owner
mkdir -p /tmp/files/scripts
ls -ld /tmp/files/scripts

# change group owner to dba
sudo chgrp dba /tmp/files/scripts
ls -ld /tmp/files/scripts

# set full access to user owner & group owner, and remove all permissions from others
sudo chmod 770 /tmp/files/scripts
touch /tmp/files/scripts/backup.sh
ls -ld /tmp/files/scripts

# check members of dba group
grep dba /etc/group

# members of dba group can now access the directory
sudo su - adwivedi
ls -ld /tmp/files/scripts

# others should get permission denied
sudo su - student
ls -l /tmp/files/scripts/




