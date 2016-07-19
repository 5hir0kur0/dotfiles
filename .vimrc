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

set background=dark

set relativenumber

" create backups and swap files in the .vim directory (the double slashes
" mean, VIM uses the full path)
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//

filetype indent plugin on

syntax on

" <Ctrl-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>

" C-c does not trigger the InsertLeave autocommand by default so you cannot
" use it to insert multiple lines at once from visual mode
inoremap <C-c> <Esc><Esc>

" force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

highlight ColorColumn ctermbg=lightblue guibg=lightblue

" enable spell checking for certain file types
autocmd FileType gitcommit setlocal spell
autocmd FileType markdown setlocal spell

colorscheme solarized

if has("mouse")
  set mouse=a
endif

"" Vundle
" from https://github.com/VundleVim/Vundle.vim/blob/master/README.md#quick-start
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-surround'
Plugin 'jiangmiao/auto-pairs'

call vundle#end()
