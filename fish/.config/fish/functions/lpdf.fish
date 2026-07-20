function lpdf -d 'build a pdf with latexmk (pdflatex) and clean up'
    if test (count $argv) -eq 0
        echo 'lpdf: missing file name' >&2
        return 1
    end
    latexmk -pdf $argv
    latexmk -c
end
