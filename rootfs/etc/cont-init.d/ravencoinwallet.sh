#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Configure user nobody to match unRAID's settings
usermod -g 100 nobody 
chmod -R u-x,go-rwx,go+u,ugo+X /storage
chown -R nobody:users /storage

# vim: set ft=sh :