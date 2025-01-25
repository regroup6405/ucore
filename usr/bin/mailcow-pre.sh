#!/usr/bin/bash
set -ex

FOLDER="/var/opt/persist/mailcow"
[ ! -d "$FOLDER" ] && git clone https://github.com/mailcow/mailcow-dockerized.git "$FOLDER" && exit 1
[ ! -d "$FOLDER"/data/assets/ssl ] && mkdir -p "$FOLDER"/data/assets/ssl

find "$FOLDER"/data | grep 'ssl-example/dhparams.pem$' | while IFS= read -r i; do
    sudo cp "$i" "$FOLDER"/data/assets/ssl/dhparams.pem
done

find /etc/ssl | grep "$(cat /etc/WEBSITE)" | grep 'fullchain.pem$' | sort | tail -n 1 | while IFS= read -r i; do
    sudo cp "$i" "$FOLDER"/data/assets/ssl/cert.pem
done

find /etc/ssl | grep "$(cat /etc/WEBSITE)" | grep 'privkey.pem$' | sort | tail -n 1 | while IFS= read -r i; do
    sudo cp "$i" "$FOLDER"/data/assets/ssl/key.pem
done

chown 1000:1000 "${FOLDER}"
exit 0
