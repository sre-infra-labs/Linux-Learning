:<<'COMMENTS'

Obtaining IP Address Configuration
----------------------------------

-> On servers, IP address configuration is set statically, using tools like nmcli (rhel), nmtui or netplan (ubuntu)

-> On workstations, IP address configuration typically is handed out by a DHCP server

-> For troubleshooting purposes, the "ip" command is used to set runtime network configuration


Using the Right Tools
-----------------------

-> Runtime networking is not persistent, but useful for analyzing what is going on

-> "ipconfig" is obsolete: it uses outdated methods for addressing and displaying networking
    and for that reason doesn't display accurate information

-> "ip" is main command for managing networking

Examples -
---------

-> ip addr add dev ens160 10.0.0.10/24

-> ip link set ens160 up

-> ip link set ens160 down

-> ip route show

-> ip route add default via 10.0.0.1




COMMENTS

