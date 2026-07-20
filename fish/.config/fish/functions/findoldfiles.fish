function findoldfiles -d 'find files not accessed in N days (default 60) under a dir (default .)'
    set -l dir (test -n "$argv[1]"; and echo $argv[1]; or echo .)
    set -l days (test -n "$argv[2]"; and echo $argv[2]; or echo 60)
    find "$dir" -atime "+$days"
end
