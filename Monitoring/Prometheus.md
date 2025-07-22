# Using Prometheus to Monitor Linux and Kubernetes
### [Github Repo](https://github.com/daveprowse/prom-live)

![Lab Setup](prometheus-lab-setup.png)

## What is Prometheus?

Prometheus is:

- A monitoring and alerting toolkit.
- Open source.
- Extensible with tools such as node_exporter, alertmanager, pg_exporter etc

## High-level Overview of Prometheus

Prometheus Server
- TSDB (Time Series Database)
- HTTP Server
- PromQL

Data Visualization
- Prometheus Web UI
- Grafana

Alert Manager
- Install on Prometheus server
- Notification/alert to email, slack, discord, pagerduty, others..

Prometheus Targets (Jobs and Exporters)
- Linux System
  - node_exporter install
- Database System
  - pg_exporter install
- Service Discovery

- Read data from API clients

![High Level Overview Diagram](prometheus-high-level-overview.png)


## Prometheus Installation
```
# copy installation scripts to downloads directory
cp -r /stale-storage/Study-Zone/Monitoring\ Alerting\ Baselining/lab-01 ~/Downloads/

# switch to downloads
cd ~/Downloads/lab-01

# make it executable
chmod +x prometheus-install-v3.4.1.sh

# install
sudo ./prometheus-install-v3.4.1.sh

# check service status
prometheus --version
sudo systemctl status prometheus
curl http://localhost:9091/

Note: To run Prometheus manually, do the following:
1. Stop the Prometheus service: 'sudo systemctl stop prometheus'

2. Run the prometheus command in case of debugging:
sudo -u prometheus /usr/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/metrics2

```

## Common locations. Mostly found in /lib/systemd/system/prometheus.service
```
# configuration file directory
/etc/prometheus/

# database location
/var/lib/prometheus/

# web configuration
/usr/share/prometheus/web/


```

## Error/Fix: listen tcp 0.0.0.0:9090: bind: address already in use
```
# Find which process is using port 9090
sudo lsof -i :9090

# Change Port (if 9090 is used by other service)
```

# Basic Querying (PromQL)
```

    up{instance="localhost:9091",job="prometheus"}

    process_resident_memory_bytes[3h]
```

# URLs/Ports
http://localhost:9000 - cockpit
http://localhost:9091 - prometheus
http://localhost:9091/alerts - prometheus/alerts
http://localhost:9093 - alertmanager
http://localhost:9100 - prometheus-node_exporter-metrics
http://localhost:9182 - prometheus-windows-exporter-metrics

# Add alert
```
cd /etc/prometheus

# add rules
sudo vim prometheus.rules.yml

# modify rule_files
sudo vim prometheus.yml

sudo systemctl restart {prometheus,alertmanager}
sudo systemctl status {prometheus,alertmanager}
```

# Instrumentation
*Instrumentation* - is the ability to monitor and measure your product's performance.

- Application
- A promethus client library
  - go
  - python
  - java
  - c/bash
  - rust

## Create Custom Exporter

#### Install required libraries
```
pip install prometheus-client psutil psycopg2-binary pymssql requests

```

#### Python Code (custom_exporter.py)
```
from prometheus_client import start_http_server, Gauge
import psutil
import socket
import psycopg2
import pymssql
import requests
import time

# --- Define Prometheus Metrics ---
fs_used_percent = Gauge('filesystem_used_percent', 'Used disk space percentage', ['mountpoint', 'device'])
postgres_up = Gauge('postgres_up', 'PostgreSQL connection status (1=UP, 0=DOWN)')
mssql_up = Gauge('mssql_up', 'MSSQL connection status (1=UP, 0=DOWN)')
grafana_up = Gauge('grafana_up', 'Grafana connection status (1=UP, 0=DOWN)')

# --- Check filesystem usage ---
def update_filesystem_metrics():
    for part in psutil.disk_partitions():
        try:
            usage = psutil.disk_usage(part.mountpoint)
            used_percent = usage.percent
            fs_used_percent.labels(mountpoint=part.mountpoint, device=part.device).set(used_percent)
        except PermissionError:
            continue

# --- Check PostgreSQL connection ---
def check_postgres():
    try:
        conn = psycopg2.connect(
            host="localhost", port=5432, user="postgres", password="postgres", dbname="postgres",
            connect_timeout=2
        )
        conn.close()
        postgres_up.set(1)
    except Exception:
        postgres_up.set(0)

# --- Check MSSQL connection ---
def check_mssql():
    try:
        conn = pymssql.connect(server='localhost', port=1432, user='sa', password='YourStrong!Passw0rd', database='master', timeout=2)
        conn.close()
        mssql_up.set(1)
    except Exception:
        mssql_up.set(0)

# --- Check Grafana HTTP availability ---
def check_grafana():
    try:
        r = requests.get('http://localhost:3000/login', timeout=2)
        grafana_up.set(1 if r.status_code == 200 else 0)
    except Exception:
        grafana_up.set(0)

# --- Main Loop ---
if __name__ == '__main__':
    print("Starting custom exporter on port 9095...")
    start_http_server(9095)

    while True:
        update_filesystem_metrics()
        check_postgres()
        check_mssql()
        check_grafana()
        time.sleep(10)


```

#### Run Exporter
```
python custom_exporter.py
```

#### Prometheus Target Configuration
```
scrape_configs:
  - job_name: 'custom-metrics'
    static_configs:
      - targets: ['localhost:9095']

```

#### Example Output at http://localhost:9095/metrics:
```
# HELP filesystem_used_percent Used disk space percentage
# TYPE filesystem_used_percent gauge
filesystem_used_percent{mountpoint="/",device="/dev/sda1"} 42.5

# HELP postgres_up PostgreSQL connection status (1=UP, 0=DOWN)
# TYPE postgres_up gauge
postgres_up 1

# HELP mssql_up MSSQL connection status (1=UP, 0=DOWN)
# TYPE mssql_up gauge
mssql_up 1

# HELP grafana_up Grafana connection status (1=UP, 0=DOWN)
# TYPE grafana_up gauge
grafana_up 1

```