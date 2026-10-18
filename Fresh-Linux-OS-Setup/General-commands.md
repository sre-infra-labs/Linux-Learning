# Linux boot process and system management

```markdown
The Linux boot process typically follows these stages:
1. BIOS/UEFI: Initializes hardware and performs POST.
2. Bootloader: GRUB loads the selected kernel and initramfs.
3. Kernel: Initializes hardware, drivers, and memory.
4. Initramfs: Provides temporary tools and drivers to mount the real root filesystem.
5. systemd: Starts services and reaches the configured target.
6. Login: Presents a console or graphical login screen.

systemd-analyze
systemd-analyze blame
journalctl -b


GRUB (GRand Unified Bootloader) loads the Linux kernel and initramfs into memory and lets you select an operating system or kernel version.
```

# How do you troubleshoot a system that is not booting?
```markdown
Use a systematic approach:
- Check BIOS/UEFI settings and boot device.
- Inspect GRUB entries and kernel parameters.
- Boot an older kernel if a recent kernel update caused the issue.
- Use rescue mode or a live ISO if the root filesystem cannot mount.
- Check filesystem, LVM, disk, and initramfs issues.
- Inspect boot logs when available.
```

## Simple commands

```bash
# get release info
cat /etc/os-release

# get kernel version
uname -a
uname -r

# Get current Desktop theme
echo $XDG_CURRENT_DESKTOP

# Get default desktop manager
cat /etc/X11/default-display-manager

# Generate password hash using mkpasswd
  # get current encryption method used for password on system
sudo getent shadow saanvi
  # use mkpasswd for getting hash using same method as above
mkpasswd --method=yescrypt


# Who Am I?
# Display current user and group identity.
id

# Alias of id --user --name
whoami

# Display who is logged in and related data (processes, boot time)
who am i

```

## Load average
```bash
htop
top
uptime
cockpit
cat /proc/loadavg
```

## Get cpu counts
```bash
lproc
cat /proc/cpuinfo
hostnamectl
```


## How to shorten command line prompt (bash prompt) & change colors
```bash
    # https://askubuntu.com/a/145626/1015062
if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='---- [\[\033[32m\]$(date +"%Y-%b-%d %H:%M:%S")\[\033[00m\]] \[\033[33m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[00m\]\n|---------- \[\033[33m\]\$\[\033[00m\] '
else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS1='---- [$(date +"%Y-%b-%d %H:%M:%S")] \u@\h:\w\n|---------- \$ '
fi


# Define colors
GREEN='\[\033[32m\]'
RED='\[\033[31m\]'
YELLOW='\[\033[33m\]'
BLUE='\[\033[34m\]'
RESET='\[\033[0m\]'

# Define a newline
NEWLINE='\n'

# Custom prompt
PS1="----- ${GREEN}[\$(date +'%Y-%b-%d %H:%M:%S')]${RESET} ${RED}\u${RESET}@${YELLOW}\h${RESET} ${BLUE}(\$(pwd | sed -e 's|.*/||'))${RESET}${NEWLINE}|------------\$ "

<# *************************************************************************** #>
I want Prompt in following format ->

---- [2024-Dec-08 19:08:19] saanvi@ryzen9:Linux-Learning
|---------- $ 


following is color coding to follow -
- timestamp should be in green
- username@host should be in yellow
- directory should be in blue
- $ should be in Yellow

<# *************************************************************************** #>
```




## Configure prompt in Mac Zsh shell (Macbook)
```bash

  # https://stackoverflow.com/a/2534676/4449743

#> nano ~/.zshrc
  -----------------------------------------------------------
  autoload -U colors && colors
  NEWLINE=$'\n'
  PS1="----- %{$fg[green]%}[%D{%G-%b-%d} %*]%{$reset_color%} %{$fg[red]%}%n%{$reset_color%}@%{$fg[yellow]%}%m %{$fg[blue]%}(%(5~|%-1~/.../%3~|%4~)) ${NEWLINE}|----------%{$reset_color%}%% "
  TMOUT=1
  TRAPALRM() {
      zle reset-prompt
  }

  -----------------------------------------------------------
```

## How do you monitor CPU and memory usage?

```bash
# CPU and load
top
uptime
mpstat -P ALL 1
vmstat 1


# Memory and swap
free -h
vmstat 1
ps aux --sort=-%mem | head
swapon --show


# Disk I/O
iostat -xz 1
iotop
```

