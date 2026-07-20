function memusage_pid -d 'sum memory usage (default pss) of a process tree'
    if test (count $argv) -eq 0
        echo 'memusage_pid: expected parent pid' >&2
        return 1
    end
    set -l parent_pid $argv[1]
    set -l mode (test -n "$argv[2]"; and echo $argv[2]; or echo pss)
    set -l all_pids (pstree -T -p $parent_pid | string match -agr '\(\d+\)' | string trim -c '()' | string join ,)
    ps -o "$mode=" --pid "$all_pids" | awk '{res += $1} END {res_mib = res / 1024; res_gib = res_mib / 1024; print res_gib "GiB =", res_mib, "MiB =", res, "KiB"}'
end
