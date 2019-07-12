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

# Adding bootstrap.
if [ "${BOOTSTRAP:-0}" -eq 1 ]; then
    log "adding bootstrap..."
	add-pkg wget ca-certificates 2>&1 | sed "s/^/[cont-init.d] $(basename $0): /"
	mkdir -p /storage/.raven 2>&1 | sed "s/^/[cont-init.d] $(basename $0): /"
	wget --progress=bar:force:noscroll http://bootstrap.ravenland.org/blockchain.tar.gz 2>&1 | sed "s/^/[cont-init.d] $(basename $0): /"
	tar -xzf blockchain.tar.gz -C /storage/.raven 2>&1 | sed "s/^/[cont-init.d] $(basename $0): /"
	rm blockchain.tar.gz 2>&1 | sed "s/^/[cont-init.d] $(basename $0): /"
fi

# check conf
grep -q "server=1" /storage/.raven/raven.conf || echo 'server=1' >> /storage/.raven/raven.conf

# Configure user nobody to match unRAID's settings
usermod -g 100 nobody 
chmod -R u-x,go-rwx,go+u,ugo+X /storage
chown -R nobody:users /storage

# vim: set ft=sh :