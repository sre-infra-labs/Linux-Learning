# Customizing Your Terminal

YouTube - https://www.youtube.com/live/AL4EUgUEt98?si=2MAtFWVgfZdSy0tL

```bash
# check all alias
alias

# create/overwrite alias
alias ll='ls -lh --color=auto'

# show shell options
set | less
set | grep PS1

# show prompt
echo $PS1

# modify alias for all users
sudo nano /etc/profile.d/

```

`profiles files` are for variables
`rc files` are for running commands


### Execution flow
```
# LOGIN shell
/etc/profile
  /etc/profile.d/*.sh
~/.bash_profile
  ~/.bashrc
    /etc/profile.d/*.sh

# NON-LOGIN shells
~/.bashrc
  /etc/profile.d/*.sh


|---------- $ sudo head /etc/profile
# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "${PS1-}" ]; then
  if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi


# add alias
nano ~/.bashrc

alias ll='ls -lahF --color=auto'
```

# Understanding `PATH`

```bash
echo $PATH

# Suppose I want to add /opt/myapp/bin directory to $PATH
nano ~/.bash_profile

export $PATH="$PATH:/opt/myapp/bin"

```

