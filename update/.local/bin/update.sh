#!/bin/bash

set -euo pipefail

ROOT=/tmp/.btrfs_root
FSTAB=~/.local/share/fstabs
SNAP_DIR=snaps

trap cleanup INT QUIT TERM EXIT
function cleanup() {
    echo 'cleanup...'
    if mount | grep -qF "$ROOT"; then
        echo "unmounting $ROOT..."
        sudo umount "$ROOT"
    fi
    if [ -d "$ROOT" ]; then
        echo "removing $ROOT..."
        rmdir "$ROOT"
    fi
}

if mount | grep -q 'on / type btrfs'; then
    if mount | grep -q "on / .*subvol=/$SNAP_DIR"; then
        echo 'SNAPSHOT MOUNTED AS ROOT; ABORTING...'
        exit 1
    fi
    echo 'mounting btrfs root...'
    mkdir "$ROOT"
    sudo mount -o subvol=/,defaults,noatime -t btrfs /dev/mapper/volgr-root "$ROOT"

    echo 'deleting snap 2...'
    sudo btrfs subvolume delete "$ROOT/$SNAP_DIR/2"

    echo 'rotating snaps...'
    sudo mv -v "$ROOT/$SNAP_DIR/1" "$ROOT/$SNAP_DIR/2"
    sudo mv -v "$ROOT/$SNAP_DIR/0" "$ROOT/$SNAP_DIR/1"

    echo 'updating fstabs...'
    sudo cp -v "$FSTAB/fstab-1" "$ROOT/$SNAP_DIR/1/etc/fstab"
    sudo cp -v "$FSTAB/fstab-2" "$ROOT/$SNAP_DIR/2/etc/fstab"

    echo 'creating snapshot...'
    sudo btrfs subvolume snapshot / "$ROOT/$SNAP_DIR/0"
    echo 'updating snapshot fstab...'
    sudo cp -v "$FSTAB/fstab-0" "$ROOT/$SNAP_DIR/0/etc/fstab"

fi

echo 'updating...'
PKGEXT=.pkg.tar command paru --sudoloop --newsonupgrade --review \
    --upgrademenu --fm ranger --nouseask --combinedupgrade --provides -Syu
sudo pacdiff
