function _my_displaytime -d 'format a number of seconds as a human-readable duration'
    set -l t $argv[1]
    set -l d (math -s0 "$t / 60 / 60 / 24")
    set -l h (math -s0 "$t / 60 / 60 % 24")
    set -l m (math -s0 "$t / 60 % 60")
    set -l s (math -s0 "$t % 60")
    set -l out ''
    test "$d" -gt 0; and set out "$out$d"'d '
    test "$h" -gt 0; and set out "$out$h"'h '
    test "$m" -gt 0; and set out "$out$m"'m '
    set out "$out$s"'s'
    echo $out
end
