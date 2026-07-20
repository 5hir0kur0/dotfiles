function mcd -d 'mkdir -p and cd into it'
    test -d "$argv[1]"; or mkdir -p "$argv[1]"
    cd "$argv[1]"; or return 1
end
