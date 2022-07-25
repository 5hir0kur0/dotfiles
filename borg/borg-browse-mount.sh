#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
source ./borg-common.sh

BROWSE_DIR=/mnt/borgbrowse

[[ -d "$BROWSE_DIR" ]] || mkdir "$BROWSE_DIR" && chmod 700 "$BROWSE_DIR"

trap 'fusermount -u $MOUNT_DIR; exit 2' INT TERM

if ! lsblk --output UUID | grep -q -F "$DISK_UUID"; then
    info "disk not found; exiting"
    exit
fi

if pgrep -x borg >/dev/null; then
    info "borg already running; exiting"
    exit
fi

export BACKUP_DIR="$MOUNT_DIR/$BORG_SUBDIR"

mount --uuid "$DISK_UUID" "$BACKUP_DIR"

info "Mounting borg repo for browsing"
borg mount -o allow_other "$BORG_REPO" "$BROWSE_DIR"
