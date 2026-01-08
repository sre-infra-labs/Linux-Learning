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

- `findmnt` - Lists all mounted filesystems and their properties.

- `mount device-path mount-point` - Mounts a device to the specified mount point.


## Directory Traversal Commands

- `cd ..` - Navigates to the parent directory.

- `cd` - Changes the current directory to the user's home.

- `cd /mnt` - Changes the current directory to /mnt.
