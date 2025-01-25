#!/bin/bash
set -e

DEST="/var/opt/persist"
FOLDER="${DEST}/nginx"

[ ! -d "$DEST" ] && mkdir -p "$DEST"
cp -r /etc/default/nginx "${DEST}"
chown 1000:1000 -R "${FOLDER}"

exit 0
