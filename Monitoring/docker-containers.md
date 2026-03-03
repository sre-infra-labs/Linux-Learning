# Docker containers

- [x] [sqlserver](https://www.mssqltips.com/sqlservertip/7099/testing-sql-server-edge-and-docker-on-the-latest-macbooks/)
- [x] postgres
- [x] monogodb
- [x] prometheous
- [x] node_exporter
- [x] grafana
- [x] postgres_exporter
- [x] mongodb_exporter


## Validations
```
docker ps --all
docker container ls
```

## Add to scrapping
```
nano /
```

## SQLServer
```
docker run -d \
  --name sqlserver \
  -p 1433:1433 \
  -e ACCEPT_EULA=1 \
  -e MSSQL_SA_PASSWORD=$MSSQLPWD_PERSONAL \
  -e MSSQL_PID=Developer  \
  mcr.microsoft.com/azure-sql-edge
```

## Postgres

```
docker run --name postgres -e POSTGRES_PASSWORD=$PGPWD_PERSONAL -p 5432:5432 -d postgres
```

## MongoDB

```
docker pull mongodb/mongodb-community-server:latest

docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=$PGPASSWORD \
  mongodb/mongodb-community-server:latest

mongosh --port 27017
mongosh "mongodb://admin:$PGPASSWORD@localhost:27017/admin"
```

## Prometheus
```
docker run --name prometheus -d -p 9090:9090 prom/prometheus

brew install prometheus
brew services start prometheus

touch /opt/homebrew/etc/prometheus.yml
nano /opt/homebrew/etc/prometheus.yml

global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets:
        - localhost:9090

  - job_name: "node_exporter"
    static_configs:
      - targets:
        - localhost:9100

prometheus --config.file=/opt/homebrew/etc/prometheus.yml # If your YAML file is in /usr/local, change accordingly
```

## postgres_exporter

```
# Start an example database
docker run --net=host -it --rm -e POSTGRES_PASSWORD=password postgres

# Connect to it
docker run \
  --name postgres_exporter \
  -d \
  -p 9187:9187 \
  -e DATA_SOURCE_URI="host.docker.internal:5432/postgres?sslmode=disable" \
  -e DATA_SOURCE_USER=postgres \
  -e DATA_SOURCE_PASS="$PGPASSWORD" \
  quay.io/prometheuscommunity/postgres-exporter

curl "http://localhost:9187/metrics"

nano /opt/homebrew/etc/prometheus.yml

- job_name: postgres_exporter
    static_configs:
      - targets:
         - "localhost:9187"
```

## mongodb_exporter

```
docker run --name mongodb_exporter -d -p 9216:9216 percona/mongodb_exporter:0.49 --mongodb.uri="mongodb://admin:$PGPASSWORD@localhost:27017/admin"

curl "http://localhost:9216/metrics"

nano /opt/homebrew/etc/prometheus.yml

  - job_name: mongodb_exporter
    static_configs:
      - targets:
        - "localhost:9216"

```