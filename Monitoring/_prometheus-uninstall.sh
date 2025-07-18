#!/bin/bash

# Uninstall script for Prometheus
# Works for the install method used in Dave Prowse's install script

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

echo
read -p "Are you sure you want to uninstall Prometheus from this system? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall canceled."
    exit 0
fi

echo
# Stop Prometheus service if running
echo "[INFO] Stopping prometheus.service if running..."
sudo systemctl stop prometheus.service 2>/dev/null

# Disable service and remove systemd unit file
echo "[INFO] Disabling and removing prometheus.service..."
sudo systemctl disable prometheus.service 2>/dev/null
sudo rm -f /etc/systemd/system/prometheus.service
sudo rm -f /usr/lib/systemd/system/prometheus.service

# Reload systemd to forget deleted unit
echo "[INFO] Reloading systemd daemon..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Remove Prometheus files (update paths as needed)
echo "[INFO] Deleting Prometheus binaries and config..."
sudo rm -f /usr/local/bin/prometheus /usr/local/bin/promtool
sudo rm -rf /etc/prometheus
sudo rm -rf /var/lib/prometheus
sudo rm -rf /opt/prometheus

# Remove prometheus user if created earlier
if id "prometheus" &>/dev/null; then
    echo "[INFO] Removing prometheus user..."
    sudo userdel -r prometheus
fi

echo "[SUCCESS] Prometheus uninstalled and cleaned from system."