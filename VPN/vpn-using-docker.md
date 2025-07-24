# [VPN using wg-easy in docker](https://www.youtube.com/watch?v=RktXcwwaYr0)

[Video tutorial](https://www.youtube.com/watch?v=RktXcwwaYr0)
[Github Repo](https://github.com/wg-easy/wg-easy)
[Basic Installation](https://wg-easy.github.io/wg-easy/latest/examples/tutorials/basic-installation/)

## Setup docker container for wg-easy with systemd service
```
# setup directory
sudo mkdir -p /etc/docker/containers/wg-easy

# download docker-compose file
sudo curl -o /etc/docker/containers/wg-easy/docker-compose.yml https://raw.githubusercontent.com/wg-easy/wg-easy/master/docker-compose.yml

# check content if required
sudo less /etc/docker/containers/wg-easy/docker-compose.yml

# create systemd service
sudo nano /etc/systemd/system/wg-easy.service

```
[Unit]
Description=WireGuard Easy VPN Docker Container
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/etc/docker/containers/wg-easy
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

# reload systemd and enable the service
sudo systemctl daemon-reload
sudo systemctl enable wg-easy
sudo systemctl start wg-easy

sudo systemctl status wg-easy

# start docker (NOT REQUIRED if running as service)
    cd /etc/docker/containers/wg-easy
    sudo docker compose up -d

# add firewall exception
sudo ufw allow 51820/udp
sudo ufw allow 51821/tcp

# Validate portal
http://localhost:51821
http://0.0.0.0:51821
http://127.0.0.1:51821

# View logs
journalctl -u wg-easy -f

docker ps -a | grep wg-easy
docker logs wg-easy


# If required to recreate container
cd /etc/docker/containers/wg-easy
sudo docker compose down
sudo docker compose up -d

```

## Setup Tunneling for Web Portal https://vpn.ajaydwivedi.com through cloudflare pointing to http://0.0.0.0:51821
[Youtube Video](https://www.youtube.com/watch?v=ey4u7OUAF3c)

## Access Ubuntu Host via Mobile using wg-easy

Open https://vpn.ajaydwivedi.com

##  Ensure Firewall Allows Forwarding
sudo ufw allow 51820/udp
sudo ufw allow OpenSSH

# Enable IP Forwarding on ryzen9 host
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Edit /etc/default/ufw
    DEFAULT_FORWARD_POLICY="ACCEPT"

# Edit /etc/ufw/sysctl.conf, and enable below line
    net/ipv4/ip_forward=1

sudo iptables -t nat -A POSTROUTING -s 10.42.42.0/24 -o wlo1 -j MASQUERADE;
sudo iptables -A FORWARD -i wg0 -j ACCEPT;
sudo iptables -A FORWARD -o wg0 -j ACCEPT;

sudo iptables -t nat -D POSTROUTING -s 10.42.42.0/24 -o wlo1 -j MASQUERADE;
sudo iptables -D FORWARD -i wg0 -j ACCEPT;
sudo iptables -D FORWARD -o wg0 -j ACCEPT;
