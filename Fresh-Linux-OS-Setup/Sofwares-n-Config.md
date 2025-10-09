# Linux Software Installation

# Install OS with inet1/inet2 adapter
![inet1-configuration-rhel](inet1-configuration-rhel.png)

# For Ansible create, following users
```
  sudo -i -u root

  adduser ansible
  addgroup sudo-nopw
  echo '%sudo-nopw ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/sudo-nopw > /dev/null
  usermod -aG sudo-nopw ansible
```

# Create Bridged Network for KVM machines
  # https://www.xmodulo.com/configure-linux-bridge-network-manager-ubuntu.html

# Configure static Ipv4 for inet1 adapter
```
  # Find ethernets
  ip link show

  # On Ubuntu, Edit network-manager-all.yaml
  sudo -i -u root
  ls -l /etc/netplan
  sudo nano /etc/netplan/01-network-manager-all.yaml
  sudo nano /etc/netplan/50-cloud-init.yaml

    # Add following content after changing ip addresses
    network:
      version: 2
      renderer: NetworkManager
      ethernets:
        enp1s0:
          dhcp4: no
          addresses: [192.168.100.36/24]
          nameservers:
            addresses: [192.168.100.10, 192.168.100.1]
          routes:
            - to: 192.168.100.0/24
              scope: link
            - to: 192.168.200.0/24
              via: 192.168.100.10

    # Apply the changes
    sudo chmod 600 /etc/netplan/01-network-manager-all.yaml
    sudo netplan apply

  # On Rhel, Edit file /etc/NetworkManager/system-connections/<link>.nmconnection
    ## Modify Configuration for internal Network (192.168.100.0/24)

      # edit connection profile with ip and dns
      sudo nmcli connection modify enp1s0 \
        connection.autoconnect yes \
        ipv4.method manual \
        ipv4.addresses "192.168.100.46/24" \
        ipv4.dns "192.168.100.10;8.8.8.8" \
        ipv4.never-default yes

      # edit connection profile to add static routes
      sudo nmcli connection modify enp1s0 \
        +ipv4.routes "192.168.100.0/24 0.0.0.0"

      sudo nmcli connection modify enp1s0 \
        +ipv4.routes "192.168.200.0/24 192.168.100.10"

    ## Configuration for LAN Network (192.168.1.0/24)

      # Edit connection profile
      sudo nmcli connection modify enp2s0 \
        connection.autoconnect yes \
        ipv4.method auto

    or

    ## Internal Network settings in /etc/NetworkManager/system-connections/<link>.nmconnection
      [connection]
      id=enp1s0
      uuid=b7f36905-d66c-461e-b8d4-60c0f81736be
      type=ethernet
      interface-name=enp1s0
      autoconnect=true
      autoconnect-priority=0

      [ethernet]

      [ipv4]
      method=manual
      address1=192.168.100.46/24
      dns=192.168.100.10;8.8.8.8;
      route1=192.168.100.0/24,0.0.0.0
      route2=192.168.200.0/24,192.168.100.10
      never-default=true

      [ipv6]
      method=disabled

      [proxy]

    ## LAN Network settings in /etc/NetworkManager/system-connections/<link>.nmconnection
      [connection]
      id=enp2s0
      uuid=eb9e5f7f-65ef-48aa-810d-229993650402
      type=ethernet
      interface-name=enp2s0
      autoconnect=true
      autoconnect-priority=0

      [ethernet]

      [ipv4]
      method=auto

      [ipv6]
      method=disabled

      [proxy]

    or

    sudo nmtui

    # fix permission, and reload settings
    sudo chmod 600 /etc/NetworkManager/system-connections/enp1s0.nmconnection
    sudo nmcli con down enp1s0
    sudo nmcli con up enp1s0
    ip addr show enp1s0
    ip route show
```

# Enable bridge interface for dhcp
```
  # On Rhel
  sudo nmcli device up enp1s0
  sudo nmcli con mod enp1s0 ipv4.method auto
  sudo nmcli con reload
  sudo nmcli con up enp1s0

  # On Ubuntu
  sudo netplan set ethernets.enp1s0.dhcp4=true
  sudo netplan apply
```

# Fix /etc/resolv.conf on Redhat OS
```
  # sudo vim /etc/resolv.conf
    search lab.com
    nameserver 192.168.100.10
    nameserver 192.168.100.1
    nameserver 8.8.8.8
  # mark /etc/resolv.conf not for change after reboot
    # sudo chattr +i /etc/resolv.conf
```


# Openssh-Server
```
  # On ubuntu
    sudo apt install -y openssh-client openssh-server
    sudo systemctl enable ssh
    sudo systemctl status ssh
    sudo ufw allow ssh

  # On Rhel
    sudo systemctl status sshd
```


# Update & upgrade
```
  sudo apt update -y && sudo apt upgrade -y
```

# Install finding utilities
```
sudo apt install fd-find plocate -y
```

# Install pip
```
  pip3 show psutil
  sudo apt install python3-pip -y
  sudo pip3 install psutil --break-system-packages
```

# guake > terminal tool
  > Set "transparency"
  > Tabs on Top
  > Title in abbreviated form

# timeshift > Backup & Recovery Tool
  > Take 1st backup

# How to Install MATE Desktop on Ubuntu 22.04
  # https://itsfoss.com/install-mate-desktop-ubuntu/
```
  sudo apt update && sudo apt upgrade -y
  sudo apt install ubuntu-mate-desktop

  Choose "lightdm".
  Choose "mate" from Login Screen.
```

# Install configuration editor
  sudo apt install dconf-editor -y

  # Configure "Disks" to mount volumes
  # Configure "MATE Tweak"
    > Panel > Redmond Layout for Win7 like taskbar
    > Desktop > Enable desktop icons
  # Configure "Control Panel" > Appearance > Themes
  > Create Home Directory Shortcuts
    > /stale-storage/shortcuts.png


  # configure password less ssh 
    # https://www.rosehosting.com/blog/how-to-enable-ssh-on-ubuntu-for-20-04-22-04/
  ssh-keygen
  ssh-copy-id saanvi@msi

# NOTE: Start a GUI software on remote SSH session
```
  ssh -X msi
  export DISPLAY=:0
  firefox

  ssh msi "DISPLAY=:0 nohup firefox"
```

# Configure /etc/hosts using SQLServerLab > Other-Scripts > etc_hosts_ubuntu.txt
```
  192.168.1.2 officelaptop
  192.168.1.3 msi
  192.168.1.4 ryzen9
  192.168.1.7 buntu
  192.168.1.10 sqlmonitor
  192.168.1.11 workstation
  192.168.1.12 sqlpractice
  192.168.1.18 pgprod
  192.168.1.20 aghost-1a
  192.168.1.21 aghost-1b

  officelaptop - 38:87:d5:c5:f7:65 - 192.168.1.2
  msi - 38:87:d5:c5:f7:65 - 192.168.1.3
  ryzen9 wifi - b4:0e:de:6f:b5:76 - 192.168.1.4
  ryzen9 lan - d8:bb:c1:3c:b2:9b - 192.168.1.5
  ryzen9 bridge0 - 1a:53:7f:1c:e4:44 - 192.168.1.6
  buntu - 52:54:00:53:c3:85 - 192.168.1.7
  sqlmonitor - 52:54:00:de:e0:76 - 192.168.1.10
  workstation - 52:54:00:ee:9a:19 - 192.168.1.11
  sqlpractice - 52:54:00:5d:d8:70 - 192.168.1.12
  experiment - 52:54:00:f0:74:ca - 
  demo - 52:54:00:b0:d4:77 - 
  sqlexpress - 52:54:00:7a:25:56 - 
  pgprod - 52:54:00:60:66:66 - 192.168.1.18
  aghost-1a - 52:54:00:eb:f5:35 - 192.168.1.20
  aghost-1b - 52:54:00:93:14:0f -  192.168.1.21
  aghost-2a - 52:54:00:4f:7e:24 - 
  aghost-2b - 52:54:00:09:31:a5 - 
  sqlprod-a - 52:54:00:78:91:21 - 
  sqldr-a - 52:54:00:d8:5d:d6 - 
  sqlprod-b - 52:54:00:66:3d:cf - 
  sqldr-b - 52:54:00:fc:30:0b - 
```

# Sofware Manager
  > sudo apt install gnome-software

# Create shortcuts in Home Directory
```
find ~ -maxdepth 1 -type l

  > ln -s /stale-storage/Personal/
  > ln -s /stale-storage/GitHub/
  > ln -s /stale-storage/Recreation-Zone/
  > ln -s /stale-storage/Softwares/
  > ln -s /stale-storage/share/
```

# Create shortcuts in subdirectories on homedirectory
```
mkdir 'Study-Videos'
cd 'Study-Videos'
find . -maxdepth 1 -type l
find . -maxdepth 1 -type l -exec sh -c 'printf "ln -s \"%s\"\n" "$(readlink -f "$1")"' _ {} \;
find . -maxdepth 1 -type l -exec sh -c 'printf "ln -s \"%s\" \"%s\"\n" "$(readlink -f "$1")" "$1"' _ {} \;

    ln -s "/stale-storage/Study-Zone/Linux/LiveLessons - Linux Under the Hood"
    ln -s "/stale-storage/Study-Zone/Python/Intermediate Python Programming Course.mp4"
    ln -s "/stale-storage/Study-Zone/Ansible/Red Hat Certified Engineer (RHCE) EX294 Red Hat Ansible Automation"
    ln -s "/stale-storage/Study-Zone/Linux/Bash Shell Scripting From Zero To Automation"
    ln -s "/stale-storage/Study-Zone/Ansible/Ansible Core Concepts and Advanced Features"
    ln -s "/stale-storage/Study-Zone/Virtualization/Docker and Kubernetes The Complete Guide"
    ln -s "/stale-storage/Study-Zone/Linux/Linux Fundamentals - 2nd Edition"
    ln -s "/stale-storage/Study-Zone/Data Structures & Algorithms/Data Structures and Algorithms The Complete Masterclass"
    ln -s "/stale-storage/Study-Zone/Ansible/Automating with Ansible"
    ln -s "/stale-storage/Study-Zone/SQL Server/BrentOzar-Recordings"
    ln -s "/stale-storage/Study-Zone/Linux/Complete Linux Bash Shell Scripting with Real Life Examples"
    ln -s "/stale-storage/Study-Zone/SQL Server/SQLSkills.com-Recording"
    ln -s "/stale-storage/Study-Zone/Data Structures & Algorithms/FreeCodeCamp - Algorithms and Data Structures Tutorial - Full Course for Beginners - 5.5 Hrs.mp4"
    ln -s "/stale-storage/Study-Zone/Virtualization/Hands-on with Podman Containers on Linux"
```

# Google Chrome
  > Setup all profiles
    > Office, Ajay, Priti, Saanvi, Anant, SqlAgentService
  > Login to Flipkart, Amazon, Github, GMail, YouTube

# Brave Browser > Advertisement free browser
  > Import profiles from other machine
  > Add home page button
  > Configure new tab settings

# Tor Browser
  > Download. Extract. Make desktop file as "Trusted".

# numlockx - Enable numlock at startup
# git
# Fonts
  > https://github.com/microsoft/cascadia-code
  > https://itsfoss.com/install-fonts-ubuntu/
  > .fonts directory in Home. Copy paste *.ttf

# VS Code
# VS Code Insiders
# Azure Data Studio

# Configure Code & Code Insiders "Git username & email"
  > git config --global user.name "Ajay Kumar Dwivedi"
  > git config --global user.email "ajay.dwivedi2007@gmail.com"

# Python
```
  > sudo apt install python-is-python3 -y
  > python --version
  > python3 --version
```

# Anaconda with Jupyter Notebook
```
  > Remove jupyter notebook & jupyter nbclassic
    conda remove nbclassic
    conda remove notebook
  > Install jupyterlab
  conda install -c conda-forge jupyterlab
  > Launch jupyterlab
  jupyter lab
```

# Akamai VPN Client Tool (eaaclient)
```
# Install from package
sudo dpkg -i /stale-storage/Softwares/Linux-Softwares-Installed/eaaclient_ubuntu_24.04.deb

# create soft link in binary path
sudo chmod +x /opt/wapp/bin/EAAClient
sudo ln -s /opt/wapp/bin/EAAClient /usr/local/bin/eaaclient

# Add software in Startup Applications.
eaaclient --no-sandbox &
eaaclient --no-sandbox %U

sudo nano /usr/share/applications/appimagekit-eaaclient.desktop
  Exec="/opt/wapp/bin/EAAClient" %U
  to
  Exec="/opt/wapp/bin/EAAClient" --no-sandbox %U

sudo update-desktop-database

```

# Slack (https://slack.com/downloads/instructions/linux?ddl=1&build=deb)
  > office
  > sqlcommunity
  > ajaydwivedi
  > Slack
  > AdminIDE Team

# Flameshot

# KVM & Virt Viewer
  > https://www.linuxtechi.com/how-to-install-kvm-on-ubuntu-22-04/
  > https://ubuntu.com/server/docs/virtualization-virt-tools
  > Reattach virtual machines
  > Ensure network ip in subnet 192.168.100.x & 192.168.200.x
  > Reboot after install

# Shared Folders (samba) when using "Ubuntu-Mate-Desktop"
```
  > https://linuxhint.com/share-folder-on-local-network-with-ubuntu/
  > sudo apt install samba smbclient caja-share
  > sudo systemctl status smbd
  > sudo ufw allow 'Samba'
  > killall caja
  > caja

  > chmod +775 /hyperactive
  > chmod +775 /vm-os/
  > chmod +775 /vm-storage-01
  > chmod +775 /vm-storage-02
  > chmod +775 /stale-storage
```

# NGinx
  > https://ubuntu.com/tutorials/install-and-configure-nginx#1-overview
  > sudo systemctl status nginx
  # configure /etc/nginx/nginx.conf from SQLServerLab > Other-Scripts > etc_nginx_nginx.conf
  > Test config file using -
    sudo nginx -t

# OBS Studio
```
  > sudo add-apt-repository ppa:obsproject/obs-studio
  > sudo apt install obs-studio
```

# Blender
```
  sudo add-apt-repository ppa:thomas-schiex/blender
  sudo apt-get update
  sudo apt-get install blender
```

# balenaEtcher
  > https://github.com/balena-io/etcher/releases

# simplescreenrecorder - SimpleScreenRecorder

# qBittorent
  > sudo apt install qbittorrent

# guvcview - Camera Testing tool
# vlc - VLC Media Player
# Stacer

# CPU-X
  > sudo apt-get install cpu-x

# Cockpit
```
  sudo apt-get install cockpit -y
  sudo systemctl enable --now cockpit.socket
  sudo usermod -aG sudo $USER
  sudo systemctl enable cockpit cockpit.socket
  sudo systemctl start cockpit cockpit.socket
  sudo ufw allow 9090/tcp

  sudo apt-get install podman cockpit-podman -y
  sudo systemctl enable --now podman

  sudo apt install -y \
      cockpit-machines \
      cockpit-ostree \
      cockpit-storaged \
      cockpit-networkmanager \
      cockpit-files \
      cockpit-sosreport

  sudo systemctl status cockpit

  sudo netstat -pnltu | grep 9090
```

# Apache Open Office
# Other common softwares
  > sudo apt install supertux tuxmath tuxpaint supertuxkart gimp notepadqq scratch gparted -y
# GCompris
  > Use "Software" application
# Zoom
# KDiskMark
  > https://github.com/JonMagon/KDiskMark/releases
# Telegram Desktop
# Postgres & PgAdmin
  > https://medium.com/@malymohsem/say-goodbye-to-downtime-upgrade-postgresql-14-to-16-effortlessly-with-pg-upgrade-42ef4dbf8524
  > https://www.postgresql.org/download/linux/ubuntu/
```
  sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update
  sudo apt-get -y install postgresql-16
  sudo pg_lsclusters
  sudo ufw allow 5432/tcp

  # check udp 1434
  nc -vuz 192.168.1.6 1434

  # check tcp 5432
  nc -vz 192.168.1.6 5432


  Conf => /etc/postgresql/16/main/postgresql.conf
  HBA File => /etc/postgresql/16/main/pg_hba.conf

  # Add postgres path in ~/.bashrc
    # Add postgres path
    export PATH="$PATH:/usr/lib/postgresql/16/bin"
    export PGDATA="/var/lib/postgresql/16/main"

  echo 'export PATH="$PATH:/usr/lib/postgresql/16/bin"' >> ~/.bashrc
  echo 'export PGDATA="/var/lib/postgresql/16/main"' >> ~/.bashrc
  source ~/.bashrc
```


  > Restore sample dbs
```
    /PostgreSQL/14/bin> pg_restore -h localhost -d dvdrental /stale-storage/Softwares/PostgreSQL/PostgreSQL-Sample-Dbs/dvdrental.tar

    > Create role before restore of forumdb
      > https://github.com/PacktPublishing/Learn-PostgreSQL-Second-Edition/tree/main/setup

    ~/Github> sudo -u postgres psql
    postgres=> select version();
    postgres=> \c postgres
    postgres=> create role luca with login password  'LearnPostgreSQL' connection limit 1;
    postgres=> create role enrico with login password 'LearnPostgreSQL';
    postgres=> CREATE ROLE forum WITH LOGIN PASSWORD 'LearnPostgreSQL';
    postgres=> CREATE DATABASE forumdb WITH OWNER forum;
    postgres=> \c forumdb
    postgres=> SET ROLE TO forum;
    postgres=> CREATE SCHEMA forum AUTHORIZATION forum;
    postgres=> SET default_tablespace = '';
    postgres=> SET default_table_access_method = heap;


    /PostgreSQL/14/bin> pg_restore -h localhost -d forumdb /stale-storage/Softwares/PostgreSQL/PostgreSQL-Sample-Dbs/forumdb.tar


  > Add new tablespace


# PowerShell
# ps modules
  > dbatools
  > sqlserver
  > importexcel
# mssql-cli
# sql server client tools
  > https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver16&tabs=redhat-install
# Office VPN
# FileZilla
# Remmina
# HTop

# ffmpeg - Video Decoding tool
  ``` ffmpeg -i tutorial-video.mp4 -i videoplayback.mp3 -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 "Vim-tutorial-for-beginners.mp4" ```
# Configure softwares for resume github repo
# XRdp
# 7Zip
# Remove orca - Screen Reader
# Setup startup applications
# Preload - Make frequent used apps

# Install Media Codecs
  > sudo apt install ubuntu-restricted-extras
    > accept EULA

# Setup Autologin for "saanvi" user
  > https://askubuntu.com/a/1202233
  > sudo nano /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
    
    autologin-user=saanvi

# Remove Password Keyrings
  > https://linuxconfig.org/how-to-disable-keyring-popup-on-ubuntu

# Install missing dependencies
  sudo apt-get install -f

# Install Kolibri on Ubuntu
  > https://learningequality.org/kolibri/download/

#Videos to Watch
  # 20 Things You MUST DO After Installing Ubuntu (Right Now!)
    # https://www.youtube.com/watch?v=GrI5c9PXS5k
  # 23 Things You MUST DO After Installing NEW Ubuntu | Ubuntu 23.10
    # https://www.youtube.com/watch?v=YFQTSkqXf3I

# Create softlinks for Study Videos
```
cd ~

ln -s "/stale-storage/GitHub"
ln -s "/stale-storage/Personal"
ln -s "/stale-storage/Recreation-Zone"
ln -s "/stale-storage/share"
ln -s "/stale-storage/Softwares"

mkdir Study-Videos
cd Study-Videos
ln -s "/stale-storage/Study-Zone/Linux/Complete Linux Bash Shell Scripting with Real Life Examples" 
ln -s "/stale-storage/Study-Zone/SQL Server/BrentOzar-Recordings"
ln -s "/stale-storage/Study-Zone/SQL Server/SQLSkills.com-Recording"
ln -s "/stale-storage/Study-Zone/Python/Complete Python Bootcamp"
ln -s "/stale-storage/Study-Zone/Python/Udemy - python-and-django-full-stack-web-developer-bootcamp"
ln -s "/stale-storage/Study-Zone/Python/Udemy - Django Core A Reference Guide to Core Django Concepts"
ln -s "/stale-storage/Study-Zone/Python/Rest API with Django Framework"
ln -s "/stale-storage/Study-Zone/Python/Intermediate Python Programming Course.mp4"
ln -s "/stale-storage/Study-Zone/Virtualization/Docker and Kubernetes The Complete Guide"
```

# Install yt-dlp for Video Downloader
https://github.com/yt-dlp/yt-dlp/wiki/Installation

wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O ~/.local/bin/yt-dlp
chmod a+rx ~/.local/bin/yt-dlp  # Make executable

yt-dlp -U

https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options


# Games to install
  # https://apps.kde.org/en-gb/categories/games/

## Language Learning (letters)
sudo apt install -y klettres

## Paint
sudo apt install -y kolourpaint

## Clone of Bomberman
sudo apt install -y granatier

## Clone of Packman
sudo apt install -y kapman

## KGoldrunner - Similar to Tobi on the Run
sudo apt install -y kgoldrunner

# TuxMath Server
sudo ss -tunap | grep tuxmath

# Check port (check connectivity on port)
nc -vz 192.168.1.6 4779

  :<<'COMMAND_OUTPUT'
(base) ----- [2025-Jan-11 19:32:29] saanvi@ryzen9 (Linux-Learning)
|------------$ sudo ss -tunap | grep tuxmath

udp   UNCONN     0      0                                  0.0.0.0:4779             0.0.0.0:*     users:(("tuxmath",pid=130513,fd=22))
tcp   LISTEN     0      5                                  0.0.0.0:4779             0.0.0.0:*     users:(("tuxmath",pid=130513,fd=21))
tcp   ESTAB      0      0                              192.168.1.6:4779         192.168.1.6:55118 users:(("tuxmath",pid=130513,fd=24))
tcp   ESTAB      0      0                              192.168.1.6:55118        192.168.1.6:4779  users:(("tuxmath",pid=130513,fd=23))

COMMAND_OUTPUT

# Install network related tools
sudo apt install -y net-tools

