#!/bin/bash

#########################################

## Updated June, 2025. Written by Dave Prowse: https://prowse.tech

## This script will install Prometheus on Ubuntu 22.04/24.04 or Debian 12 systems. 
## AMD64 and ARM64 architectures are supported.
### It can also work with CentOS but you may have to run this command: 'chcon -t bin_t '/usr/bin/prometheus'
## Prometheus will be set up as a service that runs automatically.

## This script requires that you work as `root` or with sudo capabilities. 

## !!! THIS IS FOR EDUCATIONAL PURPOSES ONLY. ONLY RUN THIS SCRIPT ON A TEST SYSTEM !!!

### TODO: systend hardening options in service file, EnvironmentFile=/etc/default/prometheus in [Service] ???, , more bash linting...

#########################################

# Variables
PROM_GITHUB_URL="https://github.com/prometheus/prometheus/releases"
printf "\nVisit \033[43;31m %s \033[0m, and note the available version you want to install. \n" "$PROM_GITHUB_URL"
printf "\n"
read -p "Enter Prometheus version to install (x.y.z)?  " PROM_VERSION_INPUT

PROMPORT="9091"
DOMAIN="localhost"
PROMVERSION="v$PROM_VERSION_INPUT"
PROM_AMD64="prometheus-$PROM_VERSION_INPUT.linux-amd64"
PROM_ARM64="prometheus-$PROM_VERSION_INPUT.linux-arm64"
UBUNTU_MAN_VERSION=noble
CERT_DIR="/etc/prometheus/certs"
WEB_CONFIG="/etc/prometheus/web.yml"


clear -x

if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL PROMETHEUS %s TO YOUR LINUX SYSTEM! \033[0m" "$PROMVERSION"
printf '%.0s\n' {1..2}
read -p "Are you sure you want to proceed? (y,n): " -r response
printf '%.0s\n' {1..2}
if [[ $response =~ ^[Yy]$ ]]; then
start=$SECONDS
printf '%.0s\n' {1..2}


echo "[INFO] Installing Prometheus with HTTPS on port $PROMPORT..."

# Install Prometheus
echo
printf "\n\033[7;32mSTARTING PROMETHEUS %s INSTALLATION IN 3 SECONDS! \033[0m" "$PROMVERSION"
echo;sleep 3;echo

# 1. Create cert directory
sudo mkdir -p "$CERT_DIR"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/prometheus.key" \
  -out "$CERT_DIR/prometheus.crt" \
  -subj "/CN=$DOMAIN"

# 2. Set permissions
    ## Create system user and directories
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus

sudo chown -R prometheus:prometheus "$CERT_DIR"
sudo chmod 600 "$CERT_DIR"/*

# 3. Create Prometheus web config
sudo tee "$WEB_CONFIG" > /dev/null <<EOF
tls_server_config:
  cert_file: "$CERT_DIR/prometheus.crt"
  key_file: "$CERT_DIR/prometheus.key"
EOF

# 4. Install Prometheus binary
mkdir temp
cd temp || return

mkdir -p /var/lib/prometheus/metrics2
mkdir -p {/etc/prometheus,/usr/share/prometheus/web}
## Download, extract, and copy Prometheus files
### Determine CPU architecture using 'uname -m'
arch=$(uname -m)
### if statement to install corresponding package based on architecture determination
if [ "$arch" == "x86_64" ]; then
    echo "Installing package for x86_64 architecture..."
    # Replace "package_name_x86_64" with the actual package name for x86_64
    wget https://github.com/prometheus/prometheus/releases/download/$PROMVERSION/$PROM_AMD64.tar.gz
    tar -xvf $PROM_AMD64.tar.gz
    cd $PROM_AMD64 || return
elif [ "$arch" == "aarch64" ]; then
    echo "Installing package for ARM64 architecture..."
    # Replace "package_name_arm64" with the actual package name for ARM64
    wget https://github.com/prometheus/prometheus/releases/download/$PROMVERSION/$PROM_ARM64.tar.gz
    tar -xvf $PROM_ARM64.tar.gz
    cd $PROM_ARM64 || return
else
    echo "Unsupported architecture: $arch"
    printf "Go to https://prometheus.io/download/ to download other binaries."
    printf '%.0s\n' {1..2}
    exit 1
fi

## Copy Prometheus files to system directories and set ownership/permissions
cp {prometheus,promtool} /usr/bin/
chown prometheus:prometheus /usr/bin/prometheus
cp -r {LICENSE,NOTICE,prometheus.yml} /etc/prometheus
chmod 664 /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /etc/prometheus


# Build Prometheus service
cat << EOF > "/lib/systemd/system/prometheus.service"
[Unit]
Description=Monitoring system and time series database (Prometheus)
Documentation=https://prometheus.io/docs/introduction/overview/ man:prometheus(1)
Wants=network-online.target
After=time-sync.target

[Service]
Restart=on-failure
User=prometheus
Group=prometheus
ExecStart=/usr/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/metrics2 \
--web.listen-address=0.0.0.0:$PROMPORT

ExecReload=/bin/kill -HUP \$MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

# Update port in config value as well
sed -i "s/\(targets: \[.*localhost:\)\([0-9]\+\)/\1$PROMPORT/" /etc/prometheus/prometheus.yml


# Start Prometheus service and re-issue ownership to database location
systemctl daemon-reload
systemctl --now enable prometheus
chown -R prometheus:prometheus /var/lib/prometheus

# Install Man pages - From Ubuntu
cd ..
wget https://manpages.ubuntu.com/manpages.gz/$UBUNTU_MAN_VERSION/man1/prometheus.1.gz
cp prometheus.1.gz /usr/share/man/man1
wget https://manpages.ubuntu.com/manpages.gz/$UBUNTU_MAN_VERSION/man1/promtool.1.gz
cp promtool.1.gz /usr/share/man/man1

# Firewall rule
export ALERTENGINEPORT=5000
export PROMPORT="$PROMPORT"
sudo ufw allow proto tcp from any to any port $PROMPORT comment "Allow Prometheus TCP port"
sudo ufw allow proto tcp from any to any port $ALERTENGINEPORT comment "Allow Alert Engine TCP port"

# Clean UP!
cd ..
rm -rf temp/
## exec new bash for users
sleep 2

# Completion messages
clear -x; echo; echo
printf "If the Prometheus version is listed below, then it is installed correctly."
printf '%.0s\n' {1..2}
prometheus --version
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! PROMETHEUS SHOULD NOW BE RUNNING AS A SERVICE.\033[0m"
printf '%.0s\n' {1..2}
echo -e "The main Prometheus configuration YAML file is at: /etc/prometheus/prometheus.yml"
printf '%.0s\n' {1..2}
echo -e "Note: To run Prometheus manually, do the following: \n
1. Stop the Prometheus service: 'sudo systemctl stop prometheus' \n
2. Run the prometheus command, for example: 'prometheus --config.file=/etc/prometheus/prometheus.yml' \n
3. Have fun! \n"
printf "\n\033[7;36m ENJOY! \033[0m"

printf '%.0s\n' {1..3}

# completion of the if-else statement
else
  echo "Installation cancelled."
fi

# 7. Done
echo "[SUCCESS] Prometheus is running at https://$DOMAIN:$PROMPORT/"