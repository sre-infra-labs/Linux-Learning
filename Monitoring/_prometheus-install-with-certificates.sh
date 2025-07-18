#!/bin/bash

PROM_GITHUB_URL="https://github.com/prometheus/prometheus/releases"
printf "\n\033[43;30mVisit %s, and note the available version you want to install. \033[0m\n\n" "$PROM_GITHUB_URL"
read -p "Enter Premetheus version to install (x.y.z)?  " PROM_VERSION_INPUT
PROMVERSION="v$PROM_VERSION_INPUT"

read -p "Enter port on which prometheus server should run (Example 9091)?  " PROMPORT

# Install dependencies
sudo apt install -y wget tar openssl firewalld

# Create certs directory
CERT_DIR="/etc/prometheus/certs"
WEB_CONFIG="/etc/prometheus/web.yml"
sudo mkdir -p $CERT_DIR
sudo openssl req -x509 -newkey rsa:4096 -sha256 -nodes \
  -keyout $CERT_DIR/privkey.pem -out $CERT_DIR/fullchain.pem \
  -days 365 -subj "/CN=localhost"

# Create prometheus user and directories
sudo useradd --no-create-home --shell /sbin/nologin prometheus
sudo mkdir -p /etc/prometheus /var/lib/prometheus/$PROMDIR
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Download and install Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/$PROMVERSION/prometheus-$PROMVERSION.linux-amd64.tar.gz
tar -xvf prometheus-$PROMVERSION.linux-amd64.tar.gz
cd prometheus-$PROMVERSION.linux-amd64

sudo cp prometheus promtool /usr/bin/
sudo cp -r consoles console_libraries /etc/prometheus/
sudo cp prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /usr/bin/prometheus /usr/bin/promtool /etc/prometheus

# Create systemd service
cat <<EOF | sudo tee /usr/lib/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Monitoring system and time series database (Prometheus)
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/$PROMDIR \\
  --web.listen-address=0.0.0.0:$PROMPORT \\
  --web.config.file=/etc/prometheus/web-config.yml

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Generate web-config.yml for TLS
cat <<EOF | sudo tee /etc/prometheus/web-config.yml > /dev/null
tls_server_config:
  cert_file: "$CERT_DIR/fullchain.pem"
  key_file: "$CERT_DIR/privkey.pem"
EOF

sudo chown prometheus:prometheus /etc/prometheus/web-config.yml

# Firewall rule
export ALERTENGINEPORT=5000
export PROMPORT="$PROMPORT"
sudo ufw allow proto tcp from any to any port $PROMPORT comment "Allow Prometheus TCP port"
sudo ufw allow proto tcp from any to any port $ALERTENGINEPORT comment "Allow Alert Engine TCP port"

# Start Prometheus
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable prometheus --now
sleep 2
sudo systemctl status prometheus
