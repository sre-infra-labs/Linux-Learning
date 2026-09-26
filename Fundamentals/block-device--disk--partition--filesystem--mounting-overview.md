# Working with Block Devices (Disks), Creating Partition, FileSystem, Mount, UnMount

```
Common Linux Block Device Overview
----------------------------------

To address disks, Linux provides devices files in /dev

/dev/sda    -> First SCSI hard disk
/dev/sdb    -> Second SCSI hard disk
/dev/vda    -> KVM hard disk
/dev/nvme0n1 -> First NVME hard disk
/dev/sr0    -> Optical drive

```


# Get Attached Disk Devices on Host using `lsblk`

```bash
# Get lsblk output in PrettyTable format
lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINTS | \
awk 'NR==1 {printf "+--------+--------+----+------+----+------+------------+\n"; 
            printf "| %-6s | %-6s | %-2s | %-4s | %-2s | %-4s | %-10s |\n", $1, $2, $3, $4, $5, $6, $7; 
            printf "+--------+--------+----+------+----+------+------------+\n"}
     NR>1  {printf "| %-6s | %-6s | %-2s | %-4s | %-2s | %-4s | %-10s |\n", $1, $2, $3, $4, $5, $6, $7} 
     END   {printf "+--------+--------+----+------+----+------+------------+\n"}'

:<<'LSBLK_COMMAND_OUTPUT'
+--------+--------+----+------+----+------+------------+
| NAME   | MAJ:MIN| RM | SIZE | RO | TYPE | MOUNTPOINTS |
+--------+--------+----+------+----+------+------------+
| sr0    | 11:0   | 1  | 1024M| 0  | rom  |            |
| zram0  | 251:0  | 0  | 7.7G | 0  | disk | [SWAP]     |
| vda    | 252:0  | 0  | 200G | 0  | disk |            |
| ├─vda1 | 252:1  | 0  | 1M   | 0  | part |            |
| ├─vda2 | 252:2  | 0  | 1G   | 0  | part | /boot      |
| └─vda3 | 252:3  | 0  | 199G | 0  | part | /home      |
|        |        |    |      |    |      | /          |
| vdb    | 252:16 | 0  | 300G | 0  | disk |            |
| vdc    | 252:32 | 0  | 20G  | 0  | disk |            |
| vdd    | 252:48 | 0  | 15G  | 0  | disk |            |
| vde    | 252:64 | 0  | 20G  | 0  | disk |            |
+--------+--------+----+------+----+------+------------+
LSBLK_COMMAND_OUTPUT


# Get block devices
lsblk --output NAME,TYPE,SIZE,FSTYPE,LABEL,FSAVAIL,MOUNTPOINTS

:<<'LSBLK_COMMAND_OUTPUT'
+-------+------+-------+-------+--------+---------+------------+
| NAME  | TYPE | SIZE  | FSTYPE| LABEL  | FSAVAIL | MOUNTPOINTS |
+-------+------+-------+-------+--------+---------+------------+
| sr0   | rom  | 1024M |       |        |         |            |
| zram0 | disk | 7.7G  |       |        |         | [SWAP]     |
| vda   | disk | 200G  |       |        |         |            |
| ├─vda1| part | 1M    |       |        |         |            |
| ├─vda2| part | 1G    | ext4  |        | 584.7M  | /boot      |
| └─vda3| part | 199G  | btrfs | fedora | 193.2G  | /home      |
|       |      |       |       |        |         | /          |
| vdb   | disk | 300G  |       |        |         |            |
| └─vdb1| part | 5G    | ext4  |        |         |            |
| vdc   | disk | 20G   |       |        |         |            |
| └─vdc1| part | 5G    |       |        |         |            |
| vdd   | disk | 15G   |       |        |         |            |
| vde   | disk | 20G   |       |        |         |            |
+-------+------+-------+-------+--------+---------+------------+
LSBLK_COMMAND_OUTPUT
```

---
---

# Creating Partitions on Disks

In order to create disk partitions, we have 2 systems - `MBR` & `GPT`


## Understanding `GPT` Partitions

`GPT` has been used since approximately 2010

In GPT, a maximum of 128 partitions can be created

GPT is required on disks bigger than 2 TB

`gdisk` is the most important utility to create GPT partitions

```bash

# Get help on gdisk
gdisk --help
tldr gdisk

:<<'GDISK_HELP'
  gdisk

  GPT (GUID Partition Table) disk partitioning tool.
  See also: `cfdisk`, `fdisk`, `parted`.
  More information: https://manned.org/gdisk.

  - List partitions:
    sudo gdisk --list

  - Start the interactive partition manipulator:
    sudo gdisk /dev/sdX

  - Open a help menu:
    <?>

  - Print the [p]artition table:
    <p>

  - Add a [n]ew partition:
    <n>

  - Select a partition to [d]elete:
    <d>

  - [w]rite table to disk and exit:
    <w>

  - [q]uit without saving changes:
    <q>
GDISK_HELP


# Work with 3rd virtual disk device (/dev/vdc)
sudo gdisk /dev/vdc

```

## Understanding `MBR` Partitions

Master Boot Record (MBR) is the old solution for addressing disks

It was introduced in 1981, together with the original PC standard

In MBR, a maximum of 4 partitions can be written to the 512 bytes boot sector

To address beyond 4 partitions, 3 are configured as primary, and 1 is configured as extended partition

Extended partitions can only be used to include logical partitions

The first logical partition is always numbered as partition #5

`fdisk` is the most important utility to create MBR partitions

```bash
# Get Help on fdisk
tldr fdisk

:<<'FDISK_HELP'
  - List partitions:
    sudo fdisk -l

  - Start the partition manipulator:
    sudo fdisk /dev/sdX

  - Add a [n]ew partition:
    n

  - Select a partition to [d]elete:
    d

  - Print the [p]artition table:
    p

  - [w]rite table to disk and exit:
    <w>

  - [q]uit without saving changes:
    <q>

  - Open a help [m]enu:
    m
FDISK_HELP

# create partition for vdb device
sudo fdisk /dev/vdb

```

## When using Logical Volumes (https://www.youtube.com/live/S5Jgw4en5ME?si=_Vl99UBLbpRfMcBO)

```bash
# BASIC Flow
Physical Disk (lsblk || blkid) -> Disk Partition (fdisk || parted || gdisk) -> Logical Physical Volume (pvs || pvcreate) -> Volume Groups (vgs || vgcreate || vgextend ) -> Logical Volumes (lvs || lvextend) -> File System (df -hT || mkfs.* || xfs_growfs)

# Figure out commands
compgen -c | sort -u | xargs -n 1 whatis 2>/dev/null | grep -i volume | grep -i group

# Figure out commands to work with physical volumes
man -k volume | grep -i physical
    :<<'COMMANDS_FOR_PHYSICAL_VOLUMES'
adwivedi@ubuntu24:~$ man -k volume | grep -i physical
lvmdiskscan (8)      - List devices that may be used as physical volumes
pvchange (8)         - Change attributes of physical volume(s)
pvck (8)             - Check metadata on physical volumes
pvcreate (8)         - Initialize physical volume(s) for use by LVM
pvdisplay (8)        - Display various attributes of physical volume(s)
pvmove (8)           - Move extents from one physical volume to another
pvremove (8)         - Remove LVM label(s) from physical volume(s)
pvresize (8)         - Resize physical volume(s)
pvs (8)              - Display information about physical volumes
pvscan (8)           - List all physical volumes
vgextend (8)         - Add physical volumes to a volume group
vgreduce (8)         - Remove physical volume(s) from a volume group
vgsplit (8)          - Move physical volumes into a new or existing volume group
COMMANDS_FOR_PHYSICAL_VOLUMES

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

---
---

# Creating File System on Partition

To use a partition, a file system must be created on top of it.

File systems are used to store files, but there are also special-purpose file systems
  that can be created on a partition.

`Swapfs` is a swap file system

`Initramfs` is a file system that is written to the Init RAM FS, which is used while booting

Generic file systems are `XFS` and `Ext4`

Use `mkfs.xfs` or "mkfs.ext4" to create these file systems.

There is no need to use file systems like vfat or NTFS, unless for formatting USB thumb drives

```bash
# Check existing file system type
df -hT

Based on existing file system Type (xfs or ext4), choose to use "mkfs.xfs" or "mkfs.ext4"

# create file system for a partition
sudo mkfs.xfs -L disk_5G /dev/vdb1

```

---

# Mounting File System

To use a partition containing a file system, it must be mounted.

By mounting a partition, it is connected to a directory.

While writing to a directory that contains a mounted partition, writes are
  actually committed to the mounted device

When the connected device is unmounted, you won't see the files that are written anymore.

Notice that mounting is also required for devices like DVD or CD-ROM

Use `mount` to mount a device for temporary basis
    `mount /dev/sdb1 /mnt`

Use `umount` to disconnect a mounted device
    `umount /mnt`

If while unmounting, the message "device is busy" appears, use `lsof` to find
  out which processes are keeping the device busy

To verify current mounts
    - mount
    - lsblk
    - df -h
    - findmnt

```bash
# list block devices excluding loop devices
lsblk -e7

# lists all current mounts
mount

# presents mounted devices, including available space
df -h

# show all mounts
findmnt

# mount device "/dev/vdd1" to path "/mnt/poc_vdd1"
sudo mkdir -p /mnt/poc_vdd1
sudo mount /dev/vdd1 /mnt/poc_vdd1

    :<<'COMMAND_OUTPUT_AFTER_MOUNTING'
    root@centos:~# mount | grep -i vdd1
    /dev/vdd1 on /mnt/poc_vdd1 type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)

    root@centos:~# lsblk
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
    └─vdd1      252:49   0    2G  0 part /mnt/poc_vdd1
    vde         252:64   0    8G  0 disk 

    root@centos:~# df -hT
    Filesystem          Type      Size  Used Avail Use% Mounted on
    /dev/mapper/cs-root xfs        39G  6.8G   32G  18% /
    devtmpfs            devtmpfs  2.3G     0  2.3G   0% /dev
    tmpfs               tmpfs     2.3G     0  2.3G   0% /dev/shm
    efivarfs            efivarfs  256K   20K  236K   8% /sys/firmware/efi/efivars
    tmpfs               tmpfs     930M   91M  840M  10% /run
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
    /dev/vda2           xfs       2.0G  575M  1.4G  29% /boot
    /dev/mapper/cs-home xfs        19G  828M   18G   5% /home
    /dev/vda1           vfat      599M   13M  586M   3% /boot/efi
    tmpfs               tmpfs     465M   56K  465M   1% /run/user/1000
    tmpfs               tmpfs     465M   72K  465M   1% /run/user/42
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyAMA0.service
    /dev/vdd1           xfs       2.0G   71M  1.9G   4% /mnt/poc_vdd1
    root@centos:~# 
COMMAND_OUTPUT_AFTER_MOUNTING

# mount a pen drive
sudo mkdir -p /mnt/usb_drive
sudo mount /dev/sdb /mnt/usb_drive

# unmount the mounted directory
sudo umount /mnt/poc_vdd1

# unmount a device
sudo umount /dev/vdd1

# if device busy error
lsof /mnt

```


---

# Making Mounts Persistent using `fstab`

```bash
# add entry for persistent mounting in /etc/fstab
sudo nano /etc/fstab

    /dev/vdb1       /disk_vdb1_5g   ext4    defaults        0 0

# validate the entry
adwivedi@pgprod:~$ sudo mount -a

    mount: /disk_vdb1_5g: mount point does not exist.
        dmesg(1) may have more information after failed mount system call.
    mount: (hint) your fstab has been modified, but systemd still uses
        the old version; use 'systemctl daemon-reload' to reload.

# fix the above error
sudo mkdir /disk_vdb1_5g

# re-validate the entry
sudo mount -a

# check mounts
mount | tail -5
sudo findmnt
sudo lsblk
sudo df -h

```

# Disk Space issue

> [!IMPORTANT]
> The scenario is called as `Open Deleted Files` where a file is deleted while it is still in use by some process in background.
> So filesystem usage still shows full, while file does not existing on directory path.

```bash

# Fill 2Gb disk /mnt/poc_vdd1 by creating a big file of 1.8 gb (95% disk utilization scenario)
cd /mnt/poc_vdd1
dd if=/dev/zero of=big_file bs=100M count=18
chmod 777 big_file
    :<<'DISK_FILESYSTEM_COMMAND_OUTPUT'

    root@centos:/mnt/poc_vdd1# df -hT
    Filesystem          Type      Size  Used Avail Use% Mounted on
    /dev/mapper/cs-root xfs        39G  6.9G   32G  18% /
    devtmpfs            devtmpfs  2.3G     0  2.3G   0% /dev
    tmpfs               tmpfs     2.3G     0  2.3G   0% /dev/shm
    efivarfs            efivarfs  256K   20K  236K   8% /sys/firmware/efi/efivars
    tmpfs               tmpfs     930M   87M  843M  10% /run
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
    /dev/vda2           xfs       2.0G  575M  1.4G  29% /boot
    /dev/mapper/cs-home xfs        19G  828M   18G   5% /home
    /dev/vda1           vfat      599M   13M  586M   3% /boot/efi
    tmpfs               tmpfs     465M   56K  465M   1% /run/user/1000
    tmpfs               tmpfs     465M   72K  465M   1% /run/user/42
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyAMA0.service
    /dev/vdd1           xfs       2.0G  1.9G  112M  95% /mnt/poc_vdd1
DISK_FILESYSTEM_COMMAND_OUTPUT

In above output, we can see that mount point /mnt/poc_vdd1 of 2 gb is full to 95%.
It is full because of `big_file`.

    :<<'DISK_USAGE_OUTPUT'
    root@centos:/mnt/poc_vdd1# du -h --max-depth=3 /mnt/poc_vdd1
    1.8G    /mnt/poc_vdd1

    root@centos:/mnt/poc_vdd1# ls -lh
    total 1.8G
    -rwxrwxrwx. 1 root root 1.8G Sep 26 17:32 big_file
DISK_USAGE_OUTPUT

# In order to generate "Deleted File Still Open" scenario, In another session, Open the big_file for reading using `tail`. KEEP IT OPEN.
tail -f /mnt/poc_vdd1/big_file

# In original session, delete the file
rm -y /mnt/poc_vdd1/big_file

# Disk FileSystem is still showing 95% used, but space usage on mount point is NOT showing any large file usage.
du --max-depth=2 -h /mnt/poc_vdd1/
ls -lh

    :<<'DISK_USAGE_OUTPUT'
    root@centos:/mnt/poc_vdd1# ls -lh
    total 0

    root@centos:/mnt/poc_vdd1# du --max-depth=2 -h /mnt/poc_vdd1/
    0       /mnt/poc_vdd1/
DISK_USAGE_OUTPUT

    :<<'DISK_FILESYSTEM_COMMAND_OUTPUT'
    root@centos:/mnt/poc_vdd1# df -hT
    Filesystem          Type      Size  Used Avail Use% Mounted on
    /dev/mapper/cs-root xfs        39G  6.9G   32G  18% /
    devtmpfs            devtmpfs  2.3G     0  2.3G   0% /dev
    tmpfs               tmpfs     2.3G     0  2.3G   0% /dev/shm
    efivarfs            efivarfs  256K   20K  236K   8% /sys/firmware/efi/efivars
    tmpfs               tmpfs     930M   87M  843M  10% /run
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
    /dev/vda2           xfs       2.0G  575M  1.4G  29% /boot
    /dev/mapper/cs-home xfs        19G  828M   18G   5% /home
    /dev/vda1           vfat      599M   13M  586M   3% /boot/efi
    tmpfs               tmpfs     465M   56K  465M   1% /run/user/1000
    tmpfs               tmpfs     465M   72K  465M   1% /run/user/42
    tmpfs               tmpfs     1.0M     0  1.0M   0% /run/credentials/serial-getty@ttyAMA0.service
    /dev/vdd1           xfs       2.0G  1.9G  112M  95% /mnt/poc_vdd1
DISK_FILESYSTEM_COMMAND_OUTPUT


# Find out processes using any file from mount point `/mnt/vdd1` having disk issue
lsof +D /path/to/directory
lsof | grep -i poc_vdd1 | grep -i deleted
    :<<'LSOF_COMMAND_OUTPUT'
    root@centos:/mnt/poc_vdd1# lsof | grep -i poc_vdd1 | grep -i deleted
    lsof: WARNING: can't stat() fuse.portal file system /run/user/42/doc
          Output information may be incomplete.
    tail      151476                        adwivedi    3r      REG             252,49 1887436800        131 /mnt/poc_vdd1/big_file (deleted)
LSOF_COMMAND_OUTPUT

Here we can notice that file /mnt/poc_vdd1/big_file marked as "deleted" is open by user adwivedi from tool "tail" under pid 151476.
The file size is 1887436800 byes (~1.8 gb).

# Kill the process which has file open to release the deleted file. -9 for terminate signal, -15 for graceful stop signal
kill -15 151476
kill -9 151476

```



