# Podman - https://www.youtube.com/live/hTD1v4aSiFY?si=dzAgWQjd5KxjDGql

# Run nginx container
`podman run -d --name web -p 8080:80 nginx`

# Check if nginx is running
```psql
curl http://localhost:8080/

# get running containers
podman ps

# get all containers
podman ps --all

# check default user
podman exec web id

    adwivedi@centos:~$ podman exec web id
    uid=0(root) gid=0(root) groups=0(root)

# Get information
podman info

# Check if it is rootless
podman info --format '{{.Host.Security.Rootless}}'

# get all podman containers running for all users
id $USER
systemd-cgls /user.slice

```

# Validate how podman container isolation works

```bash
# what processes are running and their binding with host user
  # subordinate uid (/etc/subuid) & sub gid (/etc/subgid)
podman top web user huser pid hpid
cat /etc/subuid

    adwivedi@centos:~$ id $USER
      uid=1000(adwivedi) gid=1000(adwivedi) groups=1000(adwivedi),10(wheel)
    adwivedi@centos:~$ 
    adwivedi@centos:~$ podman top web user huser pid hpid
      USER        HUSER       PID         HPID
      root        1000        1           4353
      nginx       524388      24          4377
      nginx       524388      25          4378
      nginx       524388      26          4379
      nginx       524388      27          4380
    adwivedi@centos:~$ 
    adwivedi@centos:~$ sudo cat /etc/subuid
      [sudo] password for adwivedi: 
      adwivedi:524288:65536
      anant:589824:65536
    adwivedi@centos:~$ 
    adwivedi@centos:~$ ps -awx | grep 4353
      4353 ?        Ss     0:00 nginx: master process nginx -g daemon off;
      27280 pts/0    S+     0:00 grep --color=auto 4353

```

# Enable podman containers to stay alive even after user logout

`loginctl enable-linger` allow a user's background processes, user-level systemd services, and rootless containers 
to run continuously even after the user logs out of all SSH or graphical sessions, and to start automatically at system boot

```bash
# check if lingering is enabled for any user
sudo ls -l /var/lib/systemd/linger/

# check logged in sessions
loginctl list-sessions

    SESSION  UID USER     SEAT  LEADER CLASS         TTY  IDLE SINCE 
          1   42 gdm      -     2353   manager-early -    no   -     
          3 1000 adwivedi -     3001   manager       -    no   -     
          5 1000 adwivedi -     36429  user          -    no   -     
        c1   42 gdm      seat0 2346   greeter       tty1 yes  8h ago

# terminate session
loginctl terminate-session 1

# enable lingering
loginctl enable-linger
loginctl enable-linger username

```

# Quadlets

Podman Quadlets are systemd integration files that allow you to manage and run containers natively 
using standard `.container`, `.volume`, `.network`, and `.image` unit files.

## make this directory to keep quadlets

`mkdir -p ~/.config/containers/systemd`

## Add quadlet

`nano ~/.config/containers/systemd/webapp.container`

```bash

[Unit]
Description=Rootless Nginx Demo Service

[Container]
Image=quay.io/nginx/nginx-unprivileged:alpine
PublishPort=8080:8080

[Install]
WantedBy=default.target
```

## get my services
```bash
systemctl --user daemon-reload

systemctl --user start webapp.service
systemctl --user status webapp.service
```




