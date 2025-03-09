#!/bin/bash
#set -x

ZFSNAP="$(whereis zfsnap | awk '{print $2}')"
[ ! -f "$ZFSNAP" ] && exit 1

sudo "$ZFSNAP" destroy -r "persist"

zfs list \
  | grep -v "^NAME" \
  | awk '{print $1}' \
  | while IFS= read -r i; do
      sudo zfs set refreservation=none "$i"
    done

sudo "$ZFSNAP" snapshot -a 3d -r "persist"

SOURCELIST="$(zfs list -t snap | grep @)"
TARGETDATASETS="$(ssh -n ${TARGETSSH} 'zfs list' | awk '{print $1}' | grep '/')"
TARGETLIST="$(ssh -n ${TARGETSSH} 'zfs list -t snap' | grep '@')"

echo "${SOURCELIST}" \
| grep -v 'persist@' \
| cut -d'@' -f1 \
| sort \
| uniq \
| while IFS= read -r i; do
    SOURCELATEST="$(echo "$SOURCELIST" | grep "$i" | tail -n 1 | awk '{print $1}')"
    DATASETEXISTSONTARGET="$(echo "$TARGETDATASETS" | grep -q "$i" && echo 1)"
    if [ ! "$DATASETEXISTSONTARGET" == "1" ]; then
      ssh -n ${TARGETSSH} "sudo zfs create $i"
    fi
    EXISTSONTARGET="$(echo "$TARGETLIST" | grep -q "$i" && echo 1)"
    if [ "$EXISTSONTARGET" == "1" ]; then
      echo "$i exists on target, incrementally sending..."
      TARGETLATEST="$(echo "$TARGETLIST" | grep "$i" | tail -n 1 | awk '{print $1}')"
      [ "$SOURCELATEST" == "$TARGETLATEST" ] && echo "$TARGETLATEST == $SOURCELATEST, continuing..." && continue
      echo "$TARGETLATEST > $SOURCELATEST"
      ssh -n "$TARGETSSH" sudo zfs set readonly=off "$i"
      echo sudo zfs send -i "$TARGETLATEST" "$SOURCELATEST" \| ssh ${TARGETSSH} sudo zfs recv $i | bash
    else
      echo "$i doesn't exist on target, sending from scratch..."
      ssh -n "$TARGETSSH" sudo zfs set readonly=off "$i"
      SOURCEFIRST="$(echo "$SOURCELIST" | grep "$i" | head -n 1 | awk '{print $1}')"
      echo sudo zfs send "$SOURCEFIRST" \| ssh ${TARGETSSH} sudo zfs recv -F $i | bash
      echo sudo zfs send -i "$SOURCEFIRST" "$SOURCELATEST" \| ssh ${TARGETSSH} sudo zfs recv -F $i | bash
    fi
  ssh -n "$TARGETSSH" sudo zfs set readonly=on "$i"
  done
