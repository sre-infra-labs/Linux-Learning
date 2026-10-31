#!/bin/bash

#########################################

## This script will install Prometheus on Ubuntu 22.04/24.04/26.04 or Debian 12 systems.
## AMD64, ARM64, ARMv7, PPC64LE and RISC-V (riscv64) architectures are supported.
### It can also work with CentOS but you may have to run this command: 'chcon -t bin_t '/usr/bin/prometheus'
## Prometheus will be set up as a service that runs automatically.
## By default the latest stable GitHub release is fetched automatically (pre-releases are skipped). A specific version can be chosen with -v.
## Release tarballs are verified against the sha256sums.txt published with each release.

## This script requires that you work as `root` or with sudo capabilities.

#########################################

set -euo pipefail

# Settings (override with flags or environment variables)
PROMVERSION=""                          # Set automatically to the latest stable release unless -v is given
ASSUME_YES=false                        # -y skips the confirmation prompt
PROM_USER=prometheus
PROM_CONF_DIR=/etc/prometheus
PROM_DATA_DIR=/var/lib/prometheus
PROM_PORT=9091                          # Web UI / metrics port (override with -p)
MAN_BASE_URL=https://manpages.ubuntu.com/manpages.gz

usage() {
    cat << EOF
Usage: $(basename "$0") [-v VERSION] [-y] [-h]

  -v VERSION   Install a specific stable version, e.g. 3.4.1 (default: latest stable release)
  -p PORT      Port for the Prometheus web UI (default: 9091)
  -y           Do not ask for confirmation
  -h           Show this help
EOF
}

while getopts ":v:p:yh" opt; do
    case $opt in
        v) PROMVERSION="$OPTARG" ;;
        p) PROM_PORT="$OPTARG" ;;
        y) ASSUME_YES=true ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done

# Helper: fail with a message on stderr
die() { echo "ERROR: $*" >&2; exit 1; }

# Check required commands are present before doing anything
for cmd in curl tar sha256sum awk systemctl useradd groupadd; do
    command -v "$cmd" > /dev/null 2>&1 || die "Required command not found: $cmd"
done

if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

## Determine the version to install
if [ -z "$PROMVERSION" ]; then
    # GitHub's /releases/latest skips pre-releases (rc/beta) and redirects to /releases/tag/<tag>.
    # Reading the final URL avoids the API rate limit.
    latest_url=$(curl -fsSL -o /dev/null -w '%{url_effective}' https://github.com/prometheus/prometheus/releases/latest) \
        || die "Could not determine the latest stable Prometheus release from GitHub."
    PROMVERSION="${latest_url##*/}"
fi
VERSION="${PROMVERSION#v}"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid Prometheus version: '$PROMVERSION' (expected something like 3.4.1)"
[[ "$PROM_PORT" =~ ^[0-9]+$ ]] && [ "$PROM_PORT" -ge 1 ] && [ "$PROM_PORT" -le 65535 ] || die "Invalid port: '$PROM_PORT'"

## Determine the release architecture from 'uname -m'
case "$(uname -m)" in
    x86_64|amd64)   ARCH=amd64 ;;
    aarch64|arm64)  ARCH=arm64 ;;
    armv7l)         ARCH=armv7 ;;
    ppc64le)        ARCH=ppc64le ;;
    riscv64)        ARCH=riscv64 ;;
    *)
        echo "Unsupported architecture: $(uname -m)"
        printf "Go to https://prometheus.io/download/ to download other binaries."
        printf '%.0s\n' {1..2}
        exit 1
        ;;
esac

## Ubuntu man pages are published per release codename. Use the local codename on Ubuntu, otherwise fall back to noble.
MAN_CODENAME=noble
if [ -r /etc/os-release ]; then
    # Read in subshells: os-release defines VERSION, which would overwrite the Prometheus VERSION above
    os_id=$(. /etc/os-release && echo "${ID:-}")
    os_codename=$(. /etc/os-release && echo "${VERSION_CODENAME:-}")
    if [ "$os_id" = "ubuntu" ] && [ -n "$os_codename" ]; then MAN_CODENAME="$os_codename"; fi
fi

# Clear the screen (ignored when there is no terminal)
clear -x 2> /dev/null || true

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL PROMETHEUS %s (%s) TO YOUR LINUX SYSTEM! \033[0m" "v$VERSION" "$ARCH"
printf '%.0s\n' {1..2}

if [ "$ASSUME_YES" != true ]; then
    read -r -p "Are you sure you want to proceed? (y,n): " response || true
    printf '%.0s\n' {1..2}
    if [[ ! $response =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

start=$SECONDS
printf '%.0s\n' {1..2}

# Install Prometheus
echo
printf "\n\033[7;32mSTARTING PROMETHEUS %s INSTALLATION IN 3 SECONDS! \033[0m" "v$VERSION"
echo;sleep 3;echo

## Use a private temp directory that is removed on exit (success or failure)
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT
cd "$WORKDIR"

## Download and verify the release tarball
TARBALL="prometheus-${VERSION}.linux-${ARCH}.tar.gz"
BASE_URL="https://github.com/prometheus/prometheus/releases/download/v${VERSION}"
echo "Downloading ${TARBALL}..."
curl -fsSLO "$BASE_URL/$TARBALL" || die "Download failed: $BASE_URL/$TARBALL (is version $VERSION released for $ARCH?)"
curl -fsSLO "$BASE_URL/sha256sums.txt" || die "Could not download sha256sums.txt for v$VERSION"
echo "Verifying checksum..."
awk -v f="$TARBALL" '$2 == f' sha256sums.txt | sha256sum -c - || die "Checksum verification failed for $TARBALL"

tar -xzf "$TARBALL"
cd "prometheus-${VERSION}.linux-${ARCH}"

## Create system user and directories (safe to re-run)
getent group "$PROM_USER" > /dev/null || groupadd --system "$PROM_USER"
id -u "$PROM_USER" > /dev/null 2>&1 || useradd -s /sbin/nologin --system -g "$PROM_USER" "$PROM_USER"
mkdir -p "$PROM_DATA_DIR/metrics2" "$PROM_CONF_DIR" /usr/share/prometheus/web

## Copy Prometheus files to system directories and set ownership/permissions
# Binaries are owned by root so the service user cannot modify them
install -m 0755 -o root -g root prometheus promtool /usr/bin/
cp LICENSE NOTICE "$PROM_CONF_DIR/"
# Keep an existing configuration instead of overwriting it on re-runs
if [ -f "$PROM_CONF_DIR/prometheus.yml" ]; then
    echo "Keeping existing $PROM_CONF_DIR/prometheus.yml (new default saved as prometheus.yml.new)"
    cp prometheus.yml "$PROM_CONF_DIR/prometheus.yml.new"
else
    cp prometheus.yml "$PROM_CONF_DIR/prometheus.yml"
fi
chmod 664 "$PROM_CONF_DIR/prometheus.yml"
chown -R "$PROM_USER:$PROM_USER" "$PROM_CONF_DIR"


# Build Prometheus service
cat << "EOF" > "/lib/systemd/system/prometheus.service"
[Unit]
Description=Monitoring system and time series database (Prometheus)
Documentation=https://prometheus.io/docs/introduction/overview/ man:prometheus(1)
After=time-sync.target

[Service]
Restart=on-failure
User=prometheus
Group=prometheus
ExecStart=/usr/bin/prometheus $ARGS \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/metrics2 \
--web.listen-address=:__PROM_PORT__
ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF
# Insert the chosen port (the heredoc is quoted so $ARGS and $MAINPID stay literal for systemd)
sed -i "s/__PROM_PORT__/$PROM_PORT/" /lib/systemd/system/prometheus.service

# Give the service user ownership of the database location before the service starts
chown -R "$PROM_USER:$PROM_USER" "$PROM_DATA_DIR"
systemctl daemon-reload
systemctl enable prometheus
# restart (not --now) so a re-run with a different port takes effect
systemctl restart prometheus

# Install man pages from Ubuntu (optional, skipped if unavailable for this release)
mkdir -p /usr/share/man/man1
for page in prometheus promtool; do
    if curl -fsSL "$MAN_BASE_URL/$MAN_CODENAME/man1/$page.1.gz" -o "$page.1.gz"; then
        cp "$page.1.gz" /usr/share/man/man1/
    else
        echo "Could not download the $page man page for '$MAN_CODENAME' (skipping)." >&2
    fi
done

# Clean up: the temp directory is removed by the EXIT trap
cd /
sleep 2

# Completion messages
clear -x 2> /dev/null || true; echo; echo
printf "If the Prometheus version is listed below, then it is installed correctly."
printf '%.0s\n' {1..2}
prometheus --version
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$((SECONDS - start))"
echo
printf "\n\033[7;32mPROCESS COMPLETE! PROMETHEUS SHOULD NOW BE RUNNING AS A SERVICE.\033[0m"
printf '%.0s\n' {1..2}
echo -e "The main Prometheus configuration YAML file is at: /etc/prometheus/prometheus.yml"
printf '%.0s\n' {1..2}
echo -e "Web UI: http://localhost:${PROM_PORT}  (open the firewall for port ${PROM_PORT} if you need remote access)"
printf '%.0s\n' {1..2}
echo -e "Note: To run Prometheus manually, do the following: \n
1. Stop the Prometheus service: 'sudo systemctl stop prometheus' \n
2. Run the prometheus command, for example: 'prometheus --config.file=/etc/prometheus/prometheus.yml' \n
3. Have fun! \n"
printf "\n\033[7;36m ENJOY! \033[0m"

printf '%.0s\n' {1..3}
