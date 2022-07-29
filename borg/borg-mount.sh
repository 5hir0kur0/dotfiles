#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

source ./borg-common.sh

trap 'umount $BACKUP_DIR; echo $( date ) Backup interrupted >&2; exit 2' INT TERM

if ! lsblk --output UUID | grep -q -F "$DISK_UUID"; then
    info "disk not found; exiting"
    exit 1
fi

if mount | grep -q -F "$DISK_UUID"; then
    info "disk already mounted; exiting"
    exit 1
fi

if [ ! -d "$MOUNT_DIR" ]; then
    mkdir "$MOUNT_DIR"
    chown root:root "$MOUNT_DIR"
fi
chmod 0700 "$MOUNT_DIR"

if [ ! -d "$MOUNT_DIR/$BORG_SUBDIR" ]; then
    mkdir "$MOUNT_DIR/$BORG_SUBDIR"
    chown root:root "$MOUNT_DIR/$BORG_SUBDIR"
fi
chmod 0700 "$MOUNT_DIR/$BORG_SUBDIR"

if pgrep -x borg >/dev/null; then
    info "borg already running; exiting"
    exit 1
fi

mount --uuid "$DISK_UUID" "$BACKUP_DIR"
