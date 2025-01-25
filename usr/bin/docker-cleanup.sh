#!/bin/sh

docker images -aq | while IFS= read -r i; do docker rmi -f "$i"; done
docker system prune -f
exit 0
