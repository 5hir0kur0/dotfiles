function sys_status -d 'system health summary (renamed from zsh `status`, which fish reserves as a builtin)'
    echo '    failed system services:'
    systemctl --failed
    echo '    high priority log errors:'
    journalctl -p3 -xb
    set -l disk (test -n "$argv[1]"; and echo $argv[1]; or echo /dev/sda)
    echo "    smart status of $disk:"
    sudo smartctl --health "$disk"
    if command -q pacman
        echo '    modified or missing files of installed packages:'
        pacman -Qkk 1>/dev/null
    end
end
