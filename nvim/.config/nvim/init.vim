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

" get dictionary completions using C-n/C-p in insert mode
set complete+=kspell

" display unnecessary whitespace (stolen from
" http://vim.wikia.com/wiki/Highlight_unwanted_spaces)
highlight StrayTabs ctermbg=red guibg=darkred
highlight TrailingWhitespace ctermbg=red guibg=darkred
autocmd ColorScheme * highlight StrayTabs ctermbg=red guibg=darkred
autocmd ColorScheme * highlight TrailingWhitespace ctermbg=red guibg=darkred
" match trailing whitespace, except when typing at the end of a line
match TrailingWhitespace /\s\+$/
" match tabs that are not at the start of a line
"match StrayTabs /[^\t]\zs\t\+/
" match trailing whitespace, except when typing at the end of a line
autocmd InsertEnter * match TrailingWhitespace /\s\+\%#\@<!$/
" go back to the normal highlighting in other modes
autocmd InsertLeave * match TrailingWhitespace /\s\+$/


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
" reset cursor to beam when leaving VIM
autocmd VimLeave * set guicursor=a:ver100-blinkon0

" enable mouse support (all modes)
set mouse=a

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

" remap leader to space
let mapleader = "\<Space>"

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <c-l> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr>:Gitsigns refresh<cr><c-l>

" <C-n> and <C-p> scroll without moving the relative position of the cursor
"nnoremap <silent> <C-n> <C-e>j
"nnoremap <silent> <C-p> <C-y>k

" Search for selected text, forwards or backwards.
" (stolen from https://vim.fandom.com/wiki/Search_for_visually_selected_text)
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>

" center cursor after jumping to match TODO keep or discard?
nnoremap n nzz
nnoremap N Nzz

" delete trailing whitespace
nnoremap <silent> <Leader>dW m`:%s/\s*$//<CR>:noh<CR>``
nnoremap <silent> <Leader>dw m`:s/\s*$//<CR>:noh<CR>``

" <C-c> does not trigger the InsertLeave autocommand by default so you cannot
" use it to insert multiple lines at once from visual mode
inoremap <silent> <C-c> <Esc><Esc>

" avoid <esc> delay
noremap <silent> <Esc> <Esc><Esc>

" save from insert mode
inoremap <silent> <C-s> <Esc>:update<CR>a
nnoremap <silent> <C-s> :update<CR>

" use Y for copying up to the end of the line like in DOOM Emacs
nnoremap Y y$

" use :w!! to force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

" Quick toggles for spell checking
nnoremap <Leader>se :setlocal spell spelllang=en<CR>
nnoremap <Leader>sa :setlocal spell spelllang=en_us<CR>
nnoremap <Leader>sb :setlocal spell spelllang=en_gb<CR>
nnoremap <Leader>sg :setlocal spell spelllang=de<CR>
nnoremap <Leader>sd :setlocal spell spelllang=de<CR>
nnoremap <Leader>sn :setlocal nospell<CR>

" enable spell checking for certain file types
autocmd FileType gitcommit setlocal spell spelllang=en
autocmd FileType markdown setlocal spell spelllang=en
autocmd FileType tex setlocal spell

" use man to look up the word below the cursor when K is pressed while editing
" a shell script or viewing a man page
autocmd FileType sh setlocal keywordprg=:Man
autocmd FileType man setlocal keywordprg=:Man

" use :help instead of !man to look up word below cursor with K in vim and help
" buffers
autocmd FileType vim setlocal keywordprg=:help
autocmd FileType help setlocal keywordprg=:help

" automatically save the view (cursor position, folds, etc.)
" (except for the files in the blacklists)
let filetype_blacklist = ['gitcommit', 'man']
let buftype_blacklist = ['terminal', 'help']
augroup AutoSaveFolds
    autocmd!
    autocmd BufWinLeave * if index(filetype_blacklist, &ft) < 0
                \&& index(buftype_blacklist, &bt) < 0 && @% != '' | mkview
    autocmd BufWinEnter * if index(filetype_blacklist, &ft) < 0
                \&& index(buftype_blacklist, &bt) < 0 && @% != '' | silent! loadview
augroup END

" enable filetype detection, enable file-type specific plugin loading, enable
" file-type specific indentation
filetype plugin indent on

" use true colors in terminal
set termguicolors

" enable syntax highlighting
syntax enable

let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox

" Required for operations modifying multiple buffers like rename.
set hidden

let $FZF_DEFAULT_OPTS .= ' --border --margin=0,0'

if filereadable(expand("~/.config/nvim/temp.vim"))
    source ~/.config/nvim/temp.vim
endif

" remind me of how to use diff mode -_-
if &diff
    autocmd VimEnter * echomsg "do -> :diffget (\"obtain\");  dp -> :diffput;  ]c / [c -> next/prev difference"
endif

lua require('plugins')
