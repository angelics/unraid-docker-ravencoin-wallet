#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Make sure some directories are created.
mkdir -p /storage

# Generate machine id.
log "generating machine-id..."
cat /proc/sys/kernel/random/uuid | tr -d '-' > /etc/machine-id

# Configure user nobody to match unRAID's settings
usermod -g 100 nobody 
chmod -R u-x,go-rwx,go+u,ugo+X /storage
chown -R nobody:users /storage

# vim: set ft=sh :