function llpdf -d 'build a pdf with latexmk (lualatex) and clean up'
    if test (count $argv) -eq 0
        echo 'llpdf: missing file name' >&2
        return 1
    end
    latexmk -lualatex $argv
    latexmk -c
end
