#!/bin/bash

# setleds is used to turn on the scroll lock light while a backup is running.
# hd-idle is used to spin down the disk after a backup.
# requires: borg, hd-idle, lsblk, setleds

cd -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

source ./borg-common.sh || exit 1

indicator_on() {
    setleds -L +scroll < /dev/tty1
}

indicator_off() {
    setleds -L -scroll < /dev/tty1
}

# turn on led
indicator_on

info "Starting backup"

bash ./borg-mount.sh

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

borg create                                             \
    --verbose                                           \
    --filter AME                                        \
    --list                                              \
    --stats                                             \
    --show-rc                                           \
    --compression lz4                                   \
    --exclude-caches                                    \
    --exclude '/home/*/.cache/*'                        \
    --exclude '/home/.snapshots/*'                      \
    --exclude '/home/*/.stack/*'                        \
    --exclude '/home/*/.rustup/*'                       \
    --exclude '/home/*/.cargo/*'                        \
    --exclude '/home/*/.local/share/JetBrains/*'        \
    --exclude '/home/*/.local/share/sidi/*'             \
    --exclude '/home/*/.config/chromium/*'              \
    --exclude '/home/*/.config/google-chrome/*'         \
    --exclude '/home/*/.config/JetBrains/*'             \
    --exclude '/home/*/.config/fcitx/*'                 \
    --exclude '/home/*/.subversion/*'                   \
    --exclude '/home/*/.config/libreoffice/*/cache/*'   \
    --exclude '/home/*/.local/share/Anki/QtWebEngine/*' \
    --exclude '/home/*/.local/share/flatpak/*'          \
    --exclude '/home/*/.local/share/gvfs-metadata/*'    \
    --exclude '/home/*/.local/share/nvim/swap/*'        \
    --exclude '/home/*/.local/share/nvim/view/*'        \
    --exclude '/home/*/.local/share/JetBrains/*'        \
    --exclude '/home/*/.local/share/zathura/*'          \
    --exclude '/home/*/.local/share/sddm/*'             \
    --exclude '/home/*/.swt/*'                          \
    --exclude '/home/*/.zoom/*'                         \
    --exclude '/home/*/.java/*'                         \
    --exclude '/home/*/.fehbg/*'                        \
    --exclude '/home/*/.emacs.d/cache/*'                \
    --exclude '/home/*/.emacs.d/.local/cache/'          \
    --exclude '/home/*/.thumbnails/*'                   \
    --exclude '/home/*/.visualvm/*'                     \
    --exclude '/home/*/.android/*'                      \
    --exclude '/home/*/.audacity-data/*'                \
    --exclude '/home/*/.designer/*'                     \
    --exclude '/home/*/.eclipse/*'                      \
    --exclude '/home/*/.ghc/*'                          \
    --exclude '/home/*/.vscode-oss/*'                   \
    --exclude '/home/*/.gksu.lock'                      \
    --exclude '/home/*/.mozilla/*'                      \
    --exclude '/home/*/.minecraft/*'                    \
    --exclude '/home/*/.emacs.d/*'                      \
    --exclude '/home/*/.mozc/*'                         \
    --exclude '/home/*/.Idea*/*'                        \
    --exclude '/home/*/out'                             \
    --exclude '/home/*/.vscode*/*'                      \
    --exclude '/home/*/code/go/*'                       \
    --exclude '/home/*/.mplayer*/*'                     \
    --exclude '/home/*/.texlive/*'                      \
    --exclude '/home/*/.webclipse/*'                    \
    --exclude '/home/*/.webclipse.properties'           \
    --exclude '/home/*/.config/syncthing/*'             \
    --exclude '/home/*/.config/pulse/*'                 \
    --exclude '/home/*/.config/teams/*'                 \
    --exclude '/home/*/.config/Postman/*'               \
    --exclude '/home/*/.config/Code/*'                  \
    --exclude '/home/*/.local/share/autojump/*'         \
    --exclude '/home/*/.local/share/Trash/*'            \
    --exclude '/home/*/sync/.stversions/*'              \
    --exclude '/home/*/misc/vbox/*'                     \
    --exclude '/home/*/.histfile'                       \
    --exclude '/home/*/.bash_history'                   \
    --exclude '/home/*/misc/temp/*'                     \
    --exclude '/home/*/misc/apps/*'                     \
    --exclude '/home/*/.viminfo'                        \
    --exclude '/home/*/.config/Microsoft/'              \
    --exclude '/root/.config/borg/*'                    \
    --exclude '/root/.viminfo'                          \
    --exclude '/root/.cache/*'                          \
    --exclude '/root/.local/share/autojump/*'           \
    --exclude '/root/.bash_history'                     \
    --exclude '.snapshots'                              \
    --exclude 'target'                                  \
                                                        \
    ::'{hostname}-{now}'                                \
    /etc                                                \
    /home                                               \
    /root                                               \

    backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    --glob-archives '{hostname}-*'  \
    --show-rc                       \
    --keep-hourly   24              \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  12              \

    prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
fi

bash ./borg-unmount.sh

if [ ${global_exit} -ne 0 ]; then
    for I in {1..20}; do
        indicator_on
        sleep 0.5
    done
fi

indicator_off

exit ${global_exit}
