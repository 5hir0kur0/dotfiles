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
2match StrayTabs /[^\t]\zs\t\+/
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

" enable mouse support (all modes)
set mouse=a

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

" remap leader to space
let mapleader = "\<Space>"

" <C-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <c-l> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr>:GitGutter<cr><c-l>

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
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
" Plug 'lifepillar/vim-mucomplete'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'deathlyfrantic/deoplete-spell'
Plug 'easymotion/vim-easymotion'
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
nmap <silent> <Leader>n <Plug>(ale_next_wrap)
nmap <silent> <Leader>p <Plug>(ale_previous_wrap)

" gitgutter bindings
nnoremap <silent> <Leader>gn :GitGutterNextHunk<CR>
nnoremap <silent> <Leader>gp :GitGutterPrevHunk<CR>
nnoremap <silent> <Leader>gu :GitGutterUndoHunk<CR>

" gruvbox options
let g:gruvbox_contrast_dark = 'soft'

" deoplete
let g:deoplete#enable_at_startup = 1

" stolen from https://github.com/Shougo/deoplete.nvim/issues/816
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ deoplete#manual_complete()

inoremap <silent><expr> <S-TAB>
            \ pumvisible() ? "\<C-p>" :
            \ <SID>check_back_space() ? "\<S-TAB>" :
            \ deoplete#manual_complete()

" vim-mucomplete-related options
"set completeopt+=menuone
"set completeopt+=noselect
"set shortmess+=c   " Shut off completion messages
"set belloff+=ctrlg
"let g:mucomplete#enable_auto_at_startup = 1 " enable automatic completion
"" let g:mucomplete#delayed_completion = 1
"set wildignorecase " ignore case in filename completions
"" fix compatibility with auto-pairs (stolen from mucomplete documentation)
"let g:AutoPairsMapSpace = 0
"imap <silent> <expr> <space> pumvisible()
"        \ ? "<space>"
"        \ : "<c-r>=AutoPairsSpace()<cr>"


" LanguageClient

" Required for operations modifying multiple buffers like rename.
set hidden

" for rls: rustup component add rls rust-analysis rust-src
" for pyls: pip3 install --user python-language-server
let g:LanguageClient_serverCommands = {
            \ 'rust': ['rustup', 'run', 'stable', 'rls'],
            \ 'python': ['pyls'],
            \ }

function SetLanguageClientMappings()
endfunction

function LC_maps()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <buffer> <silent> <Leader>m :call LanguageClient_contextMenu()<CR>
    nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
    nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <Leader>wgd :call LanguageClient#textDocument_definition({'gotoCmd': 'split'})<CR>
    nnoremap <buffer> <silent> <Leader>h :call LanguageClient#textDocument_documentHighlight()<CR>
    nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
    " C-F12
    nnoremap <buffer> <silent> <F36> :call LanguageClient#textDocument_documentSymbol()<CR>
  endif
endfunction

autocmd FileType * call LC_maps()

" fzf
let g:fzf_command_prefix = 'FZF'
function MyFZFGit()
    let $FZF_DEFAULT_COMMAND='git ls-files "$(git rev-parse --show-toplevel)" || find .'
    FZF
    unlet $FZF_DEFAULT_COMMAND
endfunction

nnoremap <silent> <Leader>o :call MyFZFGit()<CR>
nnoremap <silent> <Leader>O :FZF .<CR>
nnoremap <silent> <Leader>l :FZFBLines .<CR>
nnoremap <silent> <Leader>x :FZFCommands<CR>
nnoremap <silent> <Leader>p :FZFBuffers<CR>
nnoremap <silent> <Leader>H :FZFHelptags<CR>
nnoremap <silent> <Leader>M :FZFMaps<CR>


let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

let $FZF_DEFAULT_OPTS .= ' --border --margin=0,0'

function! FloatingFZF()
    let width = float2nr(&columns * 0.9)
    let height = float2nr(&lines * 0.42)
    let opts = { 'relative': 'editor',
                \ 'row': 0,
                \ 'col': (&columns - width) / 2,
                \ 'width': &columns,
                \ 'height': height }
    let win = nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    call setwinvar(win, '&winhighlight', 'NormalFloat:Normal')
    setlocal nonumber norelativenumber
endfunction

let g:fzf_layout = { 'window': 'call FloatingFZF()' }
" or
"let g:fzf_layout = { 'down': '~40%' }

" Easymotion
map <Leader> <Plug>(easymotion-prefix)

" remind me of how to use diff mode -_-
if &diff
    autocmd VimEnter * echomsg "do -> :diffget (\"obtain\");  dp -> :diffput;  ]c / [c -> next/prev difference"
endif
