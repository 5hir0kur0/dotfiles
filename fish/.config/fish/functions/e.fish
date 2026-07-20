function e -d 'open file in emacsclient, disowned'
    emacsclient $argv &
    disown
end
