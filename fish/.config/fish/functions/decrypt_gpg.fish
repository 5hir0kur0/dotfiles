function decrypt_gpg -d 'gpg --decrypt each argument, stripping its extension for the output name'
    for arg in $argv
        echo "running gpg --output $(path change-extension '' -- $arg) --decrypt $arg"
        gpg --output (path change-extension '' -- $arg) --decrypt $arg
    end
end
