# Grafana Installation

Grafana is a web dashboard that draws graphs from data sources such as Prometheus. This guide installs it on **port 3000** and sets up Google sign-in for the public address `sqlmonitor.ajaydwivedi.com`.

Works on Ubuntu 22.04/24.04/26.04 and Debian 12.

## Overview

Before you start, here are the files and services involved:

| Item | What it is | Do you edit it? |
| --- | --- | --- |
| `/etc/grafana/grafana.ini` | Grafana's default config from the package | **No.** Leave it unchanged. |
| `/etc/grafana/sqlmonitor.ini` | Your own config file with your settings | **Yes.** Created in step B1. |
| `/etc/default/grafana-server` | Tells the service which config file to use | **Yes**, one line (step B3). |
| systemd override | A small extra settings file for the `grafana-server` service, used to hold the secret | Created with a command (step B4). |

**Terms used below:**
- **Terminal:** the command-line window where you type the commands in this guide.
- **sudo:** runs a command as the administrator (root). You are asked for your password.
- **service:** a program that runs in the background. `grafana-server` is the Grafana service. Managed with `systemctl`.

## 1. Install Grafana

```bash
# install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget

# add the Grafana GPG key (proves the packages really come from Grafana)
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# add the stable Grafana repository (the place apt downloads Grafana from)
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# install Grafana
sudo apt-get update
sudo apt-get install -y grafana

# start Grafana now and on every boot
sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server

# check that it is running
sudo systemctl status grafana-server
curl -I http://localhost:3000/
```


## Common locations

```bash
# Grafana's package config (leave unchanged)
/etc/grafana/grafana.ini

# the file that tells the service which config to use
/etc/default/grafana-server

# data directory (dashboards, database)
/var/lib/grafana/

# logs
/var/log/grafana/grafana.log
journalctl -u grafana-server -n 50
```


## Configure SMTP, Google Authentication (GAuth), Github Authentication, Anonymous Authentication, Cloudflare Tunnelling

- /stale-storage/GitHub/Linux-Learning/Monitoring/ubuntu__grafana_v1.0.ini



## Error/Fix: bind: address already in use (port 3000)

This means another program is already using port 3000.

```bash
# find which program is using port 3000
sudo lsof -i :3000

# if the port must change: edit http_port in /etc/grafana/sqlmonitor.ini (step B1),
# and update the service address in the Cloudflare Tunnel (step 3.2)
sudo systemctl daemon-reload
sudo systemctl restart grafana-server
```
