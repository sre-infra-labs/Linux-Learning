# Get current Desktop theme
echo $XDG_CURRENT_DESKTOP

# Get default desktop manager
cat /etc/X11/default-display-manager

# Generate password hash using mkpasswd
  # get current encryption method used for password on system
sudo getent shadow saanvi
  # use mkpasswd for getting hash using same method as above
mkpasswd --method=yescrypt


# Load average
htop
top
uptime
cockpit
cat /proc/loadavg

# Get cpu counts
lproc
cat /proc/cpuinfo
hostnamectl


# How to shorten command line prompt (bash prompt) & change colors
    # https://askubuntu.com/a/145626/1015062
if [ "$color_prompt" = yes ]; then
    # username@host:Directory || colored prompt
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
    # username@host:Directory || colored & new line prompt
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\n\$ '
    # username@host:Directory || colored new line prompt
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\n\[\033[1;30m\]\$\[\033[00m\] '
    # [yyyy-MMM-dd HHmm] username@host:Directory || colored new line prompt
    PS1='---- [\[\033[32m\]$(date +"%Y-%b-%d %H:%M:%S")\[\033[00m\]] \[\033[33m\]\u@\h\[\033[00m\]:\[\033[34m\]\W\[\033[00m\]\n|---------- \[\033[33m\]\$\[\033[00m\] '
    #PS1='\[\033[40m\]---- [\033[32m\]$(date +"%Y-%b-%d %H:%M:%S")\[\033[00m\]] \[\033[33m\]\u@\h\[\033[00m\]:\[\033[34m\]\W\[\033[00m\]\n|---------- \[\033[33m\]\$\[\033[0m\]'
else
    # username@host:Directory
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
    # username@host:Directory || new line prompt
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\n\[\033[1;30m\]\$\[\033[00m\] '
    # [yyyy-MMM-dd HHmm] username@host:Directory || new line prompt
    PS1='---- [\[\033[32m\]$(date +"%Y-%b-%d %H:%M:%S")\[\033[00m\]] \[\033[33m\]\u@\h\[\033[00m\]:\[\033[34m\]\W\[\033[00m\]\n|---------- \[\033[33m\]\$\[\033[00m\] '
    #PS1='\[\033[40m\]---- [\033[32m\]$(date +"%Y-%b-%d %H:%M:%S")\[\033[00m\]] \[\033[33m\]\u@\h\[\033[00m\]:\[\033[34m\]\W\[\033[00m\]\n|---------- \[\033[33m\]\$\[\033[0m\]'
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




# Configure prompt in Mac Zsh shell (Macbook)
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

