#!/bin/bash

set -ouex pipefail

dnf install -y htop

TMP="$(mktemp)"
cat <<EOF > "$TMP"
docker.service
#nginx.service

portaineragent.service

autoreboot.timer
docker-cleanup.timer
EOF

cat "$TMP" | grep -v "^#" | grep '\.service$\|\.timer' | while IFS= read -r i; do
  systemctl enable "$i"
done

find /usr/bin -type f | grep '\.sh$' | sort | while IFS= read -r i; do
  chmod +x "$i"
done

[ -f "$TMP" ] && rm -f "$TMP"
