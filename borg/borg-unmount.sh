#!/bin/bash

# require: hd-idle

set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

source ./borg-common.sh

umount -R "$BACKUP_DIR"

if hash hd-idle >/dev/null 2>&1; then
    hd-idle -t disk/by-uuid/$DISK_UUID
fi
