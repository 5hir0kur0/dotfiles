set nocompatible
set ruler laststatus=2 hlsearch number showcmd title
set autoindent backup writebackup history=1337
set incsearch ignorecase smartcase
set backspace=indent,eol,start expandtab tabstop=8 shiftwidth=4 softtabstop=4
set colorcolumn=81
set wildmode=longest:full,full
set wildmenu
set list
set listchars=tab:▸\ ,eol:¬,trail:\ ,precedes:<,extends:>

set background=dark

set relativenumber

set cursorline

" create backups and swap files in the .vim directory (the double slashes
" mean, VIM uses the full path)
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//

" use :help insted of !man to look up word below cursor with K
set keywordprg=:help

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>

" <C-n> and <C-p> scroll without moving the relative position of the cursor
nnoremap <C-n> <C-e>j
nnoremap <C-p> <C-y>k

" <C-c> does not trigger the InsertLeave autocommand by default so you cannot
" use it to insert multiple lines at once from visual mode
inoremap <C-c> <Esc><Esc>

noremap <Esc> <Esc><Esc>

" force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

highlight ColorColumn ctermbg=lightblue guibg=lightblue

colorscheme gruvbox

" enable spell checking for certain file types
autocmd FileType gitcommit setlocal spell spelllang=en
autocmd FileType markdown setlocal spell spelllang=en
autocmd FileType sh setlocal keywordprg=man\ -s

let blacklist = ['help', 'txt']
augroup AutoSaveFolds
    autocmd!
    autocmd BufWinLeave * if index(blacklist, &ft) < 0 && @% != '' | mkview
    autocmd BufWinEnter * if index(blacklist, &ft) < 0 && @% != '' | silent! loadview
augroup END

set runtimepath+=~/.vim/bundle/neobundle.vim
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'w0rp/ale'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'vim-airline/vim-airline'
NeoBundle 'vim-airline/vim-airline-themes'
NeoBundle 'vim-scripts/ReplaceWithRegister'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'jiangmiao/auto-pairs'
call neobundle#end()

filetype plugin indent on
syntax enable

NeoBundleCheck

set guicursor&

" airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_exclude_preview = 0
let g:airline_left_sep = ''
let g:airline_right_sep = ''
" (lucius is also nice)
let g:airline_theme = 'minimalist'
" let g:airline_powerline_fonts = 1
let g:airline_symbols_ascii = 1

" ale bindings
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" gitgutter bindings
nnoremap <silent> <Leader>gj :GitGutterNextHunk<CR>
nnoremap <silent> <Leader>gk :GitGutterPrevHunk<CR>
nnoremap <silent> <Leader>gu :GitGutterUndoHunk<CR>
