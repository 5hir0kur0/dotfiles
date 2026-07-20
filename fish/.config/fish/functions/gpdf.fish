function gpdf -d 'recursive perl-regex grep in pdfs'
    if test (count $argv) -eq 0
        echo 'gpdf: expected a pattern' >&2
        return 1
    end
    set -l dir (test -n "$argv[2]"; and echo $argv[2]; or echo .)
    pdfgrep -iP "$argv[1]" -R "$dir"
end
