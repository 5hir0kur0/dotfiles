function brokenlinks -d 'find broken symlinks under given paths (default .)'
    set -l paths (test (count $argv) -gt 0; and echo $argv; or echo .)
    find $paths -type l -print | perl -nle '-e || print'
end
