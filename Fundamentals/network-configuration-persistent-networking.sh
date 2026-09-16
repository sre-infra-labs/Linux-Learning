:<<'COMMENTS'

Configuring Persistent Networking
----------------------------------

-> NetworkManager is the common service that takes care of persistent networking

-> To configure NetworkManager, tools like nmtui (gui based), nmcli (rhel) or netplan (ubuntu) are used

-> The configuration is written to configuration files

RHEL - https://www.youtube.com/live/nL0qZtkY-cY?si=VwXQVzhXPg5Hd3z5

# Open textual graphic interface to set network configuration
sudo nmtui

# Get an IP address for the eth0 interface:
sudo dhclient eth0

# Release an IP address for the eth0 interface:
sudo dhclient -r eth0

# Add a new connection for the enp0s8 interface:
nmcli con add con-name enp0s8 ifname enp0s8 type ethernet

# show all connection settings for the enp0s8 interface:
nmcli con show enp0s8

# Set the IP address for the enp0s8 interface
nmcli con modify enp0s8 ipv4.method manual ipv4.address 192.168.1.202 ipv4.gateway 192.168.1.1 



COMMENTS