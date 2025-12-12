:<<'COMMENTS'

Understanding Advanced Linux Permissions
----------------------------------------

-> Set User ID (SUID) (4)
    -> On files: runs the file as the user-owner of that file

-> Set Group ID (SGID) (2)
    -> On files: runs the file as the group-owner of that file
    -> On directories: sets ownership on newly created items as the group owner of that directory

-> Sticky Bit (1)
    -> On directories: allows a user to delete files if
        a) the user is file owner
        b) the user is directory owner

-> To find files with SUID
    sudo find / -type f -perm /4000 -exec ls -l {} \; 2>/dev/null

ls -l /usr/bin/passwd
    # -rwsr-xr-x 1 root root 64152 May 30  2024 /usr/bin/passwd

ls -l /etc/shadow
    # -rw-r----- 1 root shadow 2106 Jan  2 21:32 /etc/shadow


COMMENTS

# Test SUID scenario
    # make copy of /etc/hosts
    sudo cp /etc/hosts /etc/hosts_bkp

    # create a script to delete a critical file which only root can delete
    sudo vim /home/student/playme.sh
    |------------$ sudo cat /home/student/playme.sh
        #!/bin/bash

        echo do you want to play
        read

        rm /etc/hosts_bkp --no-preserve-root

    # give execute permission to the script
    sudo chmod +x /home/student/playme.sh

    # test script execution as "student"
    sudo su - student
    ls -l
        # -rwxr-xr-x 1 root root 81 Jan  4 11:26 playme.sh
    # try executing. "rm" code in script should fail as it needs root permission
    ./playme.sh
    exit

    # set SUID on the script
    sudo chmod u+s /home/student/playme.sh

    # test script execution as "student" again
    sudo -i -u student
    ls -l
        # -rwsr-xr-x 1 root root 81 Jan  4 11:26 playme.sh
    # try executing. "rm" code in script should now succeed as SUID has been set
        # NOTE: Bash Shell does not allow SUID scripts to run. So, we need to use "sh" to run the script
    ./playme.sh


# Get differential permissions
    sudo ls -l /home/student/playme.sh
        # -rwsr-xr-x 1 root root 79 Jan  4 11:58 /home/student/playme.sh

    # take snapshot of SUID files
    sudo find /home -maxdepth 2 -type f -perm /4000 > /tmp/suid_snap1.txt

    # remove SUID
    sudo chmod u-s /home/student/playme.sh
    sudo ls -l /home/student/playme.sh
        # -rwxr-xr-x 1 root root 79 Jan  4 11:58 /home/student/playme.sh

    # take snapshot of SUID files
    sudo find /home -maxdepth 2 -type f -perm /4000 > /tmp/suid_snap2.txt

    # track changes
    diff /tmp/suid_snap1.txt /tmp/suid_snap2.txt

        |------------$ diff /tmp/suid_snap1.txt /tmp/suid_snap2.txt
        1d0
        < /home/student/playme.sh

    # above result says line 1 from snap1 is missing in snap2

<<'COMMENTS'

Symbols in diff Output

    a: Added lines.
    d: Deleted lines.
    c: Changed lines.
    <: Content from the first file.
    >: Content from the second file.

A typical output -
-------------------
    2,4c2,4
    < Line from File1
    < Another line from File1
    ---
    > Line from File2
    > Another line from File2

Explanation:
-------------
    2,4c2,4: Lines 2-4 in File1 are changed to lines 2-4 in File2.
    <: Lines from File1.
    >: Lines from File2.
    ---: Separator showing difference location.

COMMENTS


# get members of "dba" group
getent group dba
grep dba /etc/group
    # dba:x:1003:saanvi,adwivedi

# create a directory for dba_files
sudo mkdir /dba_files
sudo ls -ld /dba_files
    # drwxr-xr-x 2 root root 4096 Jan  4 18:57 /dba_files

# change group ownership of dba_files to "dba"
sudo chgrp -R  dba /dba_files
sudo chmod 770 /dba_files
sudo ls -ld /dba_files
    # drwxr-xr-x 2 root dba 4096 Jan  4 18:57 /dba_files

# create files under dba_files using "saanvi" user & "adwivedi" user
sudo -u saanvi touch /dba_files/saanvi_file.txt
sudo -u adwivedi touch /dba_files/adwivedi_file.txt

# Try reading file of other user
sudo ls -la /dba_files/
    # drwxrwx---  2 root     dba      4096 Jan  4 19:06 .
    # drwxr-xr-x 29 root     root     4096 Jan  4 18:57 ..
    # -rw-rw-r--  1 adwivedi adwivedi    0 Jan  4 19:06 adwivedi_file.txt
    # -rw-rw-r--  1 saanvi   saanvi      0 Jan  4 19:06 saanvi_file.txt

saanvi@ryzen9 (~)$ echo "content added by $USER" >> /dba_files/adwivedi_file.txt
    # bash: /dba_files/adwivedi_file.txt: Permission denied

# set SGID on dba_files
sudo chmod g+s /dba_files
sudo ls -la /dba_files/
    # drwxrws---  2 root     dba      4096 Jan  4 19:06 .
    # drwxr-xr-x 29 root     root     4096 Jan  4 18:57 ..
    # -rw-rw-r--  1 adwivedi adwivedi    0 Jan  4 19:06 adwivedi_file.txt
    # -rw-rw-r--  1 saanvi   saanvi      0 Jan  4 19:06 saanvi_file.txt

# create files again
touch /dba_files/saanvi_file2.txt
sudo -u adwivedi touch /dba_files/adwivedi_file2.txt
sudo ls -la /dba_files/
    # drwxrws---  2 root     dba      4096 Jan  4 19:32 .
    # -rw-rw-r--  1 adwivedi dba         0 Jan  4 19:32 adwivedi_file2.txt
    # -rw-rw-r--  1 saanvi   dba         0 Jan  4 19:32 saanvi_file2.txt
    # -rw-rw-r--  1 adwivedi adwivedi    0 Jan  4 19:06 adwivedi_file.txt
    # -rw-rw-r--  1 saanvi   saanvi      0 Jan  4 19:06 saanvi_file.txt
    # drwxr-xr-x 29 root     root     4096 Jan  4 18:57 ..

# try adding content to other user's file. It should succeed now as SGID is set & group ownership is "dba" along with rw permission on directory
    # execute below command as "saanvi"
echo "content added by $USER" >> /dba_files/adwivedi_file.txt

# set sticky bit on dba_files to restrict deletion of files by other users
sudo chmod +t /dba_files
sudo ls -lta /dba_files/
    # -rw-rw-r--  1 adwivedi dba        24 Jan  4 19:36 adwivedi_file2.txt
    # drwxrws--T  2 root     dba      4096 Jan  4 19:32 .
    # -rw-rw-r--  1 saanvi   dba         0 Jan  4 19:32 saanvi_file2.txt
    # -rw-rw-r--  1 adwivedi adwivedi    0 Jan  4 19:06 adwivedi_file.txt
    # -rw-rw-r--  1 saanvi   saanvi      0 Jan  4 19:06 saanvi_file.txt
    # drwxr-xr-x 29 root     root     4096 Jan  4 18:57 ..

# try deleting other user's file. It should fail now as sticky bit is set
rm /dba_files/adwivedi_file2.txt
    # rm: cannot remove '/dba_files/adwivedi_file2.txt': Operation not permitted

