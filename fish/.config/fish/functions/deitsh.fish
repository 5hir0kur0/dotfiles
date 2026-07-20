function deitsh -d 'exec a shell inside a running docker container'
    if test (count $argv) -eq 0
        echo 'deitsh: expected container' >&2
        return 1
    end
    docker exec -it "$argv[1]" /bin/sh
end
