function counttypes -d 'count file mime types under given paths (default .)'
    set -l paths (test (count $argv) -gt 0; and echo $argv; or echo .)
    find $paths -type f -print0 | xargs -0 file --brief --mime | awk '
    {
        t[$0]++;
    }
    END {
        for (i in t) printf("%d\t%s\n", t[i], i);
    }' | sort -n
end
