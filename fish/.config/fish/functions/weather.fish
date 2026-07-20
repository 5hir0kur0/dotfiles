function weather
    set -l loc (test -n "$argv[1]"; and echo $argv[1]; or head -1 ~/.local/share/.location)
    curl --insecure --silent "https://wttr.in/$loc?q"
end
