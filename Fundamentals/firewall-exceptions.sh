:<<'FIREWALL_REDHAT'

Youtube - https://www.youtube.com/live/fGPzDTTiU6Q?si=400hR2QZu8oEnoL_

# List services added to firewall
sudo firewall-cmd --list-services
sudo firewall-cmd --info-service ssh


# install openssh server & configure to accept remote connections
sudo dnf install openssh-server

sudo systemctl start sshd
sudo systemctl enable sshd

sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

sudo systemctl status sshd


# More detailed analysis
firewall-cmd --info-service samba



# Install RDP package on Redhat
sudo dnf install xrdp -y  # For Debian/Ubuntu
sudo systemctl enable --now xrdp

sudo dnf install virt-viewer       # Fedora/Red Hat

sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload

sudo firewall-cmd --list-ports

# test connectivity
nc -zv <server-ip> 3389


# Zones - Zones are a set of rules that define the level of trust for network connections.
Each zone has its own set of rules and can be applied to different network interfaces. 
The default zone is usually "public", which is suitable for most users. 
You can change the default zone or assign different zones to different interfaces as needed.

# Get active firewall zone
sudo firewall-cmd --get-active-zones
    root@centos:~# sudo firewall-cmd --get-active-zones 
    public (default)
      interfaces: enp0s1

# List available zones
sudo firewall-cmd --get-zones

# Info about a specific zone
sudo firewall-cmd --info-zone=public
    root@centos:~# firewall-cmd --info-zone=public
    public (default, active)
      target: default
      ingress-priority: 0
      egress-priority: 0
      icmp-block-inversion: no
      interfaces: enp0s1
      sources: 
      services: cockpit dhcpv6-client http https ssh
      ports: 
      protocols: 
      forward: yes
      masquerade: no
      forward-ports: 
      source-ports: 
      icmp-blocks: 
      rich rules: 
FIREWALL_REDHAT


:<<'FIREWALL_UBUNTU'


# List available app profiles in firewall
sudo ufw app list

# List active app profiles in firewall
sudo ufw status verbose

# Firewall exception using application name
sudo ufw allow 'OpenSSH'


# Install RDP package on Ubuntu & add firewall exception
sudo apt install virt-viewer        # Debian/Ubuntu


sudo ufw allow 9090/tcp
sudo ufw allow 'Samba'

# space port
sudo ufw allow 5900/tcp


remote-viewer spice://<host_ip>:<port>


# Port troubleshooting
nmap ubuntu

    root@centos:~# nmap ubuntu
    Starting Nmap 7.92 ( https://nmap.org ) at 2026-09-17 10:43 IST
    Nmap scan report for ubuntu (192.168.64.3)
    Host is up (0.00030s latency).
    rDNS record for 192.168.64.3: ubuntu24
    Not shown: 999 closed tcp ports (reset)
    PORT   STATE SERVICE
    22/tcp open  ssh
    MAC Address: 1E:B4:11:DA:D0:B5 (Unknown)

    Nmap done: 1 IP address (1 host up) scanned in 0.43 seconds


# Get port info mapping to service
sudo less /etc/services

FIREWALL_UBUNTU


