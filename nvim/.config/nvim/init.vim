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

" show preview of the effect of ":" commands (like :s) while typing
set inccommand=nosplit

" minimal number of screen columns to keep to the left and to the right of the
" cursor
set sidescrolloff=10

" also use gui cursor in terminal (the cursor changes in insert mode)
set guicursor&

"set termguicolors

" don't redraw during macros, etc.
set lazyredraw

" highlight column 81 (so you can avoid typing text longer than 80 cols)
" TODO change this so text beyond column 80 gets highlighted instead of the
" column itself
set colorcolumn=81
"highlight ColorColumn ctermbg=lightblue guibg=lightblue
"let g:m2=matchadd('SpellBad', '\%>80v.\+', -1)

" create backups, swap files and undo files in the .local directory
" (the double slashes mean, VIM uses the full path [not sure if true,
" no mention of this in the documentation as far as I can tell,
" but it doesn't hurt...])
set backupdir=~/.local/share/nvim/backup//
set directory=~/.local/share/nvim/swap//
set undodir=~/.local/share/nvim/undo//

" save undo history to a file
set undofile

" use escape to exit out of terminal input
tnoremap <Esc> <C-\><C-n>

" use :help insted of !man to look up word below cursor with K
set keywordprg=:help

" remap leader to space
let mapleader = "\<Space>"

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <c-l> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr>:GitGutter<cr><c-l>

" <C-n> and <C-p> scroll without moving the relative position of the cursor
nnoremap <silent> <C-n> <C-e>j
nnoremap <silent> <C-p> <C-y>k

" center cursor after jumping to match TODO keep or discard?
nnoremap n nzz
nnoremap N Nzz

" <C-c> does not trigger the InsertLeave autocommand by default so you cannot
" use it to insert multiple lines at once from visual mode
inoremap <silent> <C-c> <Esc><Esc>

" avoid <esc> delay
noremap <silent> <Esc> <Esc><Esc>

" save from insert mode
inoremap <silent> <C-s> <Esc>:update<CR>a
nnoremap <silent> <C-s> :update<CR>

" use :w!! to force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

" enable spell checking for certain file types
autocmd FileType gitcommit setlocal spell spelllang=en
autocmd FileType markdown setlocal spell spelllang=en

" use man to look up the word below the cursor when K is pressed while editing
" a shell script
autocmd FileType sh setlocal keywordprg=man\ -s

" latex files
autocmd FileType tex setlocal spell

" automatically save the view (cursor position, folds, etc.)
" (except for the files in blacklist)
let blacklist = ['help', 'txt']
augroup AutoSaveFolds
    autocmd!
    autocmd BufWinLeave * if index(blacklist, &ft) < 0 && @% != '' | mkview
    autocmd BufWinEnter * if index(blacklist, &ft) < 0 && @% != '' | silent! loadview
augroup END

call plug#begin('~/.local/share/nvim/plugged')
Plug 'junegunn/vim-plug'
Plug 'w0rp/ale'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'lifepillar/vim-solarized8'
Plug 'morhetz/gruvbox'
Plug 'lifepillar/vim-mucomplete'
call plug#end()

" enable filetype detection, enable file-type specific plugin loading, enable
" file-type specific indentation
filetype plugin indent on

" use true colors in terminal
set termguicolors

" enable syntax highlighting
syntax enable

colorscheme gruvbox

" airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_exclude_preview = 0
let g:airline_left_sep = ''
let g:airline_right_sep = ''
" (minimalist is also nice)
let g:airline_theme = 'lucius'
" let g:airline_powerline_fonts = 1
"let g:airline_symbols_ascii = 1

" ale bindings
nmap <silent> <Leader>j <Plug>(ale_next_wrap)
nmap <silent> <Leader>k <Plug>(ale_previous_wrap)

" gitgutter bindings
nnoremap <silent> <Leader>gj :GitGutterNextHunk<CR>
nnoremap <silent> <Leader>gk :GitGutterPrevHunk<CR>
nnoremap <silent> <Leader>gu :GitGutterUndoHunk<CR>

" gruvbox options
let g:gruvbox_contrast_dark = 'soft'

" latex-live-preview options
let g:livepreview_previewer = 'zathura'

" vim-mucomplete-related options
set completeopt+=menuone
set completeopt+=noselect
set shortmess+=c   " Shut off completion messages
set belloff+=ctrlg"
let g:mucomplete#enable_auto_at_startup = 1 " enable automatic completion
" let g:mucomplete#delayed_completion = 1
set wildignorecase " ignore case in filename completions

" fix compatibility with auto-pairs (stolen from mucomplete documentation)
let g:AutoPairsMapSpace = 0
imap <silent> <expr> <space> pumvisible()
        \ ? "<space>"
        \ : "<c-r>=AutoPairsSpace()<cr>"
