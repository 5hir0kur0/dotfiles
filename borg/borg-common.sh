#!/bin/bash

# UUID of the disk containing the borg repository
DISK_UUID='{{Insert UUID here}}'
# username of the user who should receive the notifications (used if `notify` fails, see below)
NOTFIY_USER=$(ls /home | grep -vF 'lost+found|sbox|sandbox' | head -n 1)

MOUNT_DIR=/mnt
BORG_SUBDIR=borgmount
REPO_NAME=borg
export BACKUP_DIR=$MOUNT_DIR/$BORG_SUBDIR

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=$BACKUP_DIR/$REPO_NAME

# Setting this, so you won't be asked for your repository passphrase:
export BORG_PASSPHRASE='{{Insert Passphrase here}}'

# some helpers and error handling:
notify() {
    local wm_pids
    if ! wm_pids=$(pgrep -x '(i3|gnome-shell)'); then
        return 1
    fi
    for pid in $wm_pids; do
        eval "$(grep -z ^USER /proc/"$pid"/environ | tr '\000' '\n')"
        eval export "$(grep -z ^DISPLAY /proc/"$pid"/environ | tr '\000' '\n')"
        eval export "$(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/"$pid"/environ | tr '\000' '\n')"

        su "$USER" -c "notify-send '$*'"
    done
}

info() {
    local info_message
    info_message=$(printf "%s %s" "$( date '+%H:%M' )" "$*")
    printf "\n%s\n\n" "$info_message" >&2
    if ! notify "$info_message"; then
        if [ -n "$NOTFIY_USER" ]; then
            DISPLAY=:0 sudo -u "$NOTFIY_USER" notify-send "$info_message"
        fi
    fi
}
