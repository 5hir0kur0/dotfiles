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

" C-c does not trigger the InsertLeave autocommand by default so you cannot
" use it to insert multiple lines at once from visual mode
inoremap <C-c> <Esc><Esc>

inoremap { {<CR>}<Esc>O

"force saving files that require root permission 
cnoremap w!! w !sudo tee > /dev/null %

highlight ColorColumn ctermbg=lightblue guibg=lightblue
highlight LineNr ctermbg=darkgrey ctermfg=darkblue guibg=darkgrey guifg=darkblue

colorscheme base16-solarized

if has("mouse")
  set mouse=a
endif
