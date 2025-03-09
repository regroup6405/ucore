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

git clone https://github.com/zfsnap/zfsnap.git /usr/src/zfsnap
cp /usr/src/zfsnap/sbin/zfsnap.sh /usr/sbin/zfsnap
cp /usr/src/zfsnap/man/man8/zfsnap.8 /usr/share/man/man8/zfsnap.8
cp -r /usr/src/zfsnap/share /usr
chmod +x /usr/sbin/zfsnap
rm -rf /usr/src/zfsnap

cat "$TMP" | grep -v "^#" | grep '\.service$\|\.timer' | while IFS= read -r i; do
  systemctl enable "$i"
done

find /usr/bin -type f | grep '\.sh$' | sort | while IFS= read -r i; do
  chmod +x "$i"
done

[ -f "$TMP" ] && rm -f "$TMP"
