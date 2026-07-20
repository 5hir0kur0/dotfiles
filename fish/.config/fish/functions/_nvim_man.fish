function _nvim_man -d 'wrap the man command in nvim so syntax highlighting works'
    nvim "+Man $argv | bd #"
end
