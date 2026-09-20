# [Basic Linux Commands](https://linuxopsys.substack.com/p/75-essential-linux-command?publication_id=4995647&post_id=166530869&isFreemail=true&r=1tltv8&triedRedirect=true)

## System-Based Commands

- `uname` - Displays system information: kernel version, machine type, and more.

- `uname -r` - Displays the running Linux kernel's release version.

- `uptime` - Shows current time, system uptime, users, and load averages.

- `hostname` - Shows the system hostname.

- `hostname -i` - Displays the IP address of the current host.

- `last reboot` - Shows last reboot times and durations in logs.

- `date` - Displays the current date and time information.

- `timedatectl` - Displays detailed system clock and time zone information.

- `cal` - Displays a simple calendar of the current month.

- `w` - Shows who is logged on and their activity.

- `whoami` - Displays the username of the current user.

- `who am i` - Display who is logged in and related data.

- `finger username` - Displays information about a user named username.


## Hardware-Based Commands

- `dmesg` - Displays messages from the kernel's ring buffer.

- `cat /proc/cpuinfo` - Displays detailed information about the CPU.

- `cat /proc/meminfo` - Displays detailed system memory usage information.

- `lscpu` - Lists information about the CPU.

- `lshw` - Lists detailed hardware configuration of the system.

- `lsblk` - Lists information about all available block devices.

- `free -m` - Shows system memory usage in megabytes.

- `lspci -tv` - Displays PCI devices in tree format, verbosely.

- `lsusb -tv` - Shows USB devices as a tree, verbosely.

- `dmidecode` - Displays hardware information from system BIOS.

- `hdparm -i /dev/sda` - Displays information of disk /dev/sda.

- `badblocks -s /dev/sda` - Checks /dev/sda for bad blocks, showing progress.


## User Management Commands

- `id` - Displays the user's UID, GID, and groups.

- `last` - Shows list of last logged-in users.

- `who` - Displays who is currently logged in.

- `groupadd admin` - Creates a new user group named admin.

- `adduser Sam` - Creates a new user account named Sam.

- `userdel Sam` - Deletes the user account named Sam.

- `usermod` - Modifies properties of an existing user account.


## File Commands

- `ls -al` - Lists all files, with detailed information, in long format.

- `pwd` - Displays the present working directory's path.

- `mkdir dir1` - Creates a new directory named dir1.

- `rm file1` - Deletes the file named file1.

- `rm -f file2` - Forcefully deletes the file named file2.

- `rm -r dir1` - Recursively removes directory dir1 and its contents.

- `rm -rf dir1` - Forcefully deletes directory dir1 and its contents.

- `cp file1 file2` - Copies file1, creating or overwriting file2.

- `cp -r dir1 dir2` - Copies dir1 to dir2, including subdirectories.

- `mv file1 file2` - Renames or moves file1 to file2.

- `ln -s /path/to/file_name link_name` - Creates symbolic link named link_name to file_name.

- `touch file1` - Creates an empty file named file1.

- `cat > file1` - Creates or overwrites file1, awaiting standard input.

- `more file1` - Displays file1 content, paginating through output.

- `head file1` - Displays the first ten lines of file1.

- `tail file1` - Displays the last ten lines of file1.

- `gpg -c file1` - Encrypts file1 with a symmetric cipher using a passphrase.

- `gpg file2.gpg` - Decrypts file2.gpg, prompting for the passphrase.

- `wc` - Counts words, lines, and characters in files.

- `xargs` - Executes commands with piped or file-provided arguments.


## Network Commands

- `ip addr show` - Displays all network interfaces and their information.

- `ip address add 192.168.0.1/24 dev eth0` - Assigns IP address 192.168.0.1 to interface eth0.

- `ifconfig` - Shows network interfaces and their configuration.

- `ping host` - Sends ICMP packets, measures round-trip time to host.

- `whois domain` - Retrieves and displays a domain's registration information.

- `dig domain` - Queries DNS, provides domain's DNS information.

- `dig -x host` - Resolves IP address to hostname, shows reverse DNS info.

- `host google.com` - Performs an IP lookup for the domain name.

- `wget file_path` - Downloads file from the specified path.

- `netstat` - Displays various network-related information and statistics.

- `ss` - Displays information about network sockets.


## Compression / Archive Commands

- `tar -cf backup.tar /home/ubuntu` - Creates a tar archive of the /home/ubuntu directory.

- `tar -xf backup.tar` - Extracts files from the backup.tar archive.

- `tar -zcvf backup.tar.gz /home/ubuntu` - Creates compressed backup.tar.gz archive of /home/ubuntu.

- `gzip file1` - Compresses file1 into file1.gz; original file is removed.


## Install Packages Commands

- `rpm -i pkg_name.rpm` - Installs the package pkg_name.rpm using RPM.

- `rpm -e pkg_name` - Uninstalls the specified RPM package.

- `dnf install pkg_name` - Installs the specified package using DNF.

- `pacman -S pkg_name` - Installs the specified package using Pacman.


## Install from Source (Compilation)

- `./configure` - Checks system compatibility and generates Makefile.

- `make` - Compiles code using the Makefile.

- `make install` - Installs compiled code into appropriate system locations.


## Search Commands

- `grep pattern file` - Searches for a given pattern within the specified file.

- `grep -r pattern dir1` - Recursively searches for pattern in directory dir1.

- `locate file` - Finds files named file using a prebuilt index database.

- `find /home -name index` - Searches /home for files named index.

- `find /home -size +10000k` - Finds files over 10,000 KB in /home.


## Login Commands

- `ssh user@hostname` - Initiates SSH connection to specified host.

- `ssh -p port_number user@hostname` - Connects over SSH using a specific port.

- `ssh hostname` - Connects to hostname using SSH on port 22.

- `telnet host` - Connects to host via Telnet on port 23.


## File Transfer Commands

- `scp file.txt remoteuser@remote_host:/remote/directory` - Copies file.txt to a remote directory.

- `rsync -a /home/ubuntu /backup/` - Synchronizes /home/ubuntu to /backup/, preserving attributes.

- `rsync -a /var/www/web/ user@remote_host:/backup/web_backup/` - Syncs local directory to remote backup.


## Disk Usage Commands

- `df -h` - Shows human-readable disk space usage.

- `df -i` - Shows inode usage for all mounted filesystems.

- `fdisk -l` - Lists all partitions and information for all drives.

- `du -sh /dir1` - Displays total disk usage of /dir1 in human-readable form.
```
sudo du --max-depth=1 /var | sort -nr | numfmt --field 1 --to iec --format "%-10f" | head -n 10
```

- `findmnt` - Lists all mounted filesystems and their properties.

- `mount device-path mount-point` - Mounts a device to the specified mount point.


## When using Logical Volumes (https://www.youtube.com/live/S5Jgw4en5ME?si=_Vl99UBLbpRfMcBO)

```bash
# BASIC Flow
Physical Disk (lsblk || blkid) -> Disk Partition (fdisk || parted || gdisk) -> Logical Physical Volume (pvs || pvcreate) -> Volume Groups (vgs || vgcreate || vgextend ) -> Logical Volumes (lvs || lvextend) -> File System (df -hT || mkfs.* || xfs_growfs)

# Figure out commands
compgen -c | sort -u | xargs -n 1 whatis 2>/dev/null | grep -i volume | grep -i group
man -k volume | grep -i group

# Fill your disk by creating a large file
cd ~
dd if=/dev/zero of=big_file

# Fill your diks to 16 gb (total 18)
dd if=/dev/zero of=big_file bs=1G count=16

# Check File System. With option T, we get Type info as well.
df -hT

    Filesystem          Type      Size  Used Avail Use% Mounted on
    /dev/mapper/cs-root xfs        39G  5.4G   34G  14% /
    devtmpfs            devtmpfs  1.8G     0  1.8G   0% /dev
    tmpfs               tmpfs     1.8G     0  1.8G   0% /dev/shm
    efivarfs            efivarfs  256K   20K  237K   8% /sys/firmware/efi/efivars
    tmpfs               tmpfs     716M   11M  705M   2% /run
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
    /dev/mapper/cs-home xfs        19G   17G  2.2G  89% /home
    /dev/vda2           xfs       2.0G  435M  1.6G  22% /boot
    /dev/vda1           vfat      599M   13M  586M   3% /boot/efi
    tmpfs               tmpfs     358M   56K  358M   1% /run/user/1000
    tmpfs               tmpfs     358M   76K  358M   1% /run/user/42
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyAMA0.service

# List block devices. This will help us indentify if we are using logical volumes in `TYPE` attribute
lsblk -fs

    NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    sr0          11:0    1 1024M  0 rom  
    vda         252:0    0   64G  0 disk 
    ├─vda1      252:1    0  600M  0 part /boot/efi
    ├─vda2      252:2    0    2G  0 part /boot
    └─vda3      252:3    0 61.4G  0 part 
      ├─cs-root 253:0    0 38.6G  0 lvm  /
      ├─cs-swap 253:1    0  3.9G  0 lvm  [SWAP]
      └─cs-home 253:2    0 18.9G  0 lvm  /home
    vdb         252:16   0    5G  0 disk 
    vdc         252:32   0    8G  0 disk 
    vdd         252:48   0    2G  0 disk 
    vde         252:64   0    8G  0 disk 

# Get available volume groups
vgs

      VG #PV #LV #SN Attr    VSize  VFree
      cs   1   3   0 wz--n-- 61.41g    0 

# Get available logical volumes
lvs

# Get physical volumes
pvs

# If there is free space in volume group, then increase the space on logical volume
sudo lvextend --extents +100%FREE --resizefs /dev/mapper/cs-home

#or just increase the logical volume size. Not filesystem
sudo lvextend --extents +100%FREE /dev/mapper/cs-home

# since filesystem type is xfs (check df -hT), we use xfs utilities to grow filesystem
sudo xfs_growfs /dev/mapper/cs-home

# Convert a physical disk to physical volume
sudo pvcreate /dev/vdd

    adwivedi@centos:~$ sudo pvcreate /dev/vdd
    WARNING: xfs signature detected on /dev/vdd at offset 0. Wipe it? [y/n]: y
      Wiping xfs signature on /dev/vdd.
      Physical volume "/dev/vdd" successfully created.

sudo pvs
    adwivedi@centos:~$ sudo pvs
    PV         VG Fmt  Attr PSize  PFree
    /dev/vda3  cs lvm2 a--  61.41g    0
    /dev/vdd      lvm2 ---   2.00g 2.00g

# Add PV to VG
sudo vgs
    adwivedi@centos:~$ sudo vgs
      VG #PV #LV #SN Attr    VSize  VFree
      cs   1   3   0 wz--n-- 61.41g    0 

sudo vgextend cs /dev/vdd
    adwivedi@centos:~$ sudo vgextend cs /dev/vdd
      Volume group "cs" successfully extended

```


## Directory Traversal Commands

- `cd ..` - Navigates to the parent directory.

- `cd` - Changes the current directory to the user's home.

- `cd /mnt` - Changes the current directory to /mnt.
