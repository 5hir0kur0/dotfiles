" disable vi compatibility
set nocompatible

" show line/column number and relative position
set ruler

" always show status line
set laststatus=2

" highlight search matches
set hlsearch

" show line numbers
set number

" show (partial) commands on screen (in operator pending or visual mode)
set showcmd

" set the title of the terminal window to the current filename
set title

set autoindent

" create backup before overwriting the file and don't delete it afterwards
set writebackup backup

" keep a history of ":" commands
set history=10000

" show search results while typing and ignore case except when the search
" string contains a capital letter
set incsearch ignorecase smartcase

" allow backspace over indentation, end of line, and the point where insert
" mode was started
set backspace=indent,eol,start

" insert the appropriate number of spaces if <tab> is pressed in insert mode
set expandtab

" number of spaces that a <tab> character counts for
" (this is *not* the number of spaces that gets inserted when you press <tab>
" in insert mode)
set tabstop=8

" number of spaces used for each step auf (auto)indent
set shiftwidth=4

" number of spaces that are inserted by <tab> and deleted by <bs>
set softtabstop=4

" better completion in command mode
set wildmenu wildmode=longest:full,full

" display non-printable characters (such as tabs and newlines)
set list

" how to display non-printable characters
set listchars=tab:▸\ ,eol:¬,trail:\·,precedes:◀,extends:▶

" display unnecessary whitespace (stolen from
" http://vim.wikia.com/wiki/Highlight_unwanted_spaces)
highlight ExtraWhitespace ctermbg=red guibg=darkred
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=darkred

" match trailing whitespace, except when typing at the end of a line
match ExtraWhitespace /\s\+\%#\@<!$/
" match tabs that are not at the start of a line
match ExtraWhitespace /[^\t]\zs\t\+/

set background=dark

" show line numbers relative to the line the cursor is on
set relativenumber

" highlight the line of the cursor
set cursorline

" use <f10> to toggle the 'paste' option
set pastetoggle=<F10>

" don't redraw during macros, etc.
set lazyredraw

" create backups and swap files in the .vim directory (the double slashes
" mean, VIM uses the full path)
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//
set undodir=~/.vim/undo//

" save undo history to a file
set undofile

" encryption method
set cryptmethod=blowfish2

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
nnoremap <silent> <c-l> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr>:GitGutter<cr><c-l>

" <C-n> and <C-p> scroll without moving the relative position of the cursor
nnoremap <silent> <C-n> <C-e>j
nnoremap <silent> <C-p> <C-y>k

" <C-n> and <C-p> behave like arrow keys in command mode
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

"remap leader to space
let mapleader = "\<Space>"

" delete trailing whitespace
nnoremap <silent> <Leader>W m`:s/\s*$//<CR>:noh<CR>``
nnoremap <silent> <Leader>w m`g_ld$``

" <C-c> does not trigger the InsertLeave autocommand by default so you cannot
" use it to insert multiple lines at once from visual mode
inoremap <C-c> <Esc><Esc>

noremap <Esc> <Esc><Esc>

" save from insert mode
inoremap <silent> <C-s> <Esc>:update<CR>a
nnoremap <silent> <C-s> :update<CR>

nnoremap n nzz
nnoremap N Nzz

" force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

set colorcolumn=81
highlight ColorColumn ctermbg=lightblue guibg=lightblue

" enable spell checking for certain file types
autocmd FileType gitcommit setlocal spell
autocmd FileType markdown setlocal spell
autocmd FileType sh setlocal keywordprg=man\ -s

"" Vundle
" from https://github.com/VundleVim/Vundle.vim/blob/master/README.md#quick-start
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-unimpaired'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/ReplaceWithRegister'
Plugin 'w0rp/ale'
Plugin 'airblade/vim-gitgutter'
Plugin 'morhetz/gruvbox'
Plugin 'jiangmiao/auto-pairs'

call vundle#end()

colorscheme gruvbox

" airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_exclude_preview = 0
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_theme = 'lucius'
let g:airline_symbols_ascii = 1

" ale bindings
nmap <silent> <Leader>j <Plug>(ale_next_wrap)
nmap <silent> <Leader>k <Plug>(ale_previous_wrap)

" gitgutter bindings
nnoremap <silent> <Leader>gj :GitGutterNextHunk<CR>
nnoremap <silent> <Leader>gk :GitGutterPrevHunk<CR>
nnoremap <silent> <Leader>gu :GitGutterUndoHunk<CR>
