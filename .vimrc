set nocompatible
set ruler laststatus=2 hlsearch number showcmd title
set autoindent backup writebackup history=1337
set incsearch ignorecase smartcase
set backspace=indent,eol,start expandtab tabstop=8 shiftwidth=4 softtabstop=4
set colorcolumn=81
set wildmode=longest,list,full
set wildmenu
set list
set listchars=tab:▸\ ,eol:¬,trail:\ ,precedes:↤,extends:↦

" highlight the line the cursor is on
set cursorline

set background=dark

set relativenumber

set pastetoggle=<F10>

" create backups and swap files in the .vim directory (the double slashes
" mean, VIM uses the full path)
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//

" use :help insted of !man to look up word below cursor with K
set keywordprg=:help

if has("gui")
    " clean up GUI
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
endif

filetype indent plugin on

syntax on

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <c-l> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" <C-n> and <C-p> scroll without moving the relative position of the cursor
nnoremap <silent> <C-n> <C-e>j
nnoremap <silent> <C-p> <C-y>k

" <C-n> and <C-p> behave like arrow keys in command mode
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"remap leader to space
let mapleader = "\<Space>"

" delete trailing whitespace
nnoremap <Leader>W m`:s/\s*$//<CR>:noh<CR>``
nnoremap <Leader>w m`g_ld$``

" <C-c> does not trigger the InsertLeave autocommand by default so you cannot
" use it to insert multiple lines at once from visual mode
inoremap <C-c> <Esc><Esc>

noremap <Esc> <Esc><Esc>

" force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

highlight ColorColumn ctermbg=lightblue guibg=lightblue

" enable spell checking for certain file types
autocmd FileType gitcommit setlocal spell
autocmd FileType markdown setlocal spell
autocmd FileType sh setlocal keywordprg=man\ -s

colorscheme solarized

"" Vundle
" from https://github.com/VundleVim/Vundle.vim/blob/master/README.md#quick-start
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-commentary'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/ReplaceWithRegister'
Plugin 'w0rp/ale'

call vundle#end()

" airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_exclude_preview = 0
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_theme = 'tomorrow'

" ale settings
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
