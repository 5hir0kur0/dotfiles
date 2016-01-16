set nocompatible
set ruler laststatus=2 hlsearch number showcmd title
set autoindent backup writebackup history=1337
set incsearch ignorecase smartcase
set backspace=indent,eol,start expandtab tabstop=8 shiftwidth=2 softtabstop=4 
set colorcolumn=81
set wildmode=longest,list,full
set wildmenu

set background=dark

filetype indent plugin on

syntax on

"replace tabs with spaces
retab

"<Ctrl-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>

inoremap { {<CR>}<Esc>O

highlight ColorColumn ctermbg=lightblue guibg=lightblue
highlight LineNr ctermbg=darkgrey ctermfg=darkblue guibg=darkgrey guifg=darkblue

colorscheme base16-default

if has("mouse")
  set mouse=a
endif
