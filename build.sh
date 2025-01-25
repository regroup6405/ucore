#!/bin/bash

set -ouex pipefail

dnf install -y htop

systemctl enable docker.service
systemctl enable portaineragent.service
systemctl enable autoreboot.timer

find /usr/bin -type f | grep '\.sh$' | sort | while IFS= read -r i; do
  chmod +x "$i"
done
