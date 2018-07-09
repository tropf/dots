set nocompatible              " be iMproved, required
filetype off                  " required

set encoding=utf-8

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" check minimum version
if v:version > 705 || (v:version == 704 && has('patch1578'))
    " YouCompleteMe only works when python is enabled
    if has("python") || has("python3")
        " requires cmake
        if executable("cmake")
            Plugin 'Valloric/YouCompleteMe'
        endif
    endif
endif
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.

" vim airline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" pretty aligned tables
Plugin 'godlygeek/tabular'

" vim Markdown support (also customized syntax highlighting)
Plugin 'tpope/vim-markdown'

" cobalt2 color scheme
Plugin 'tropf/cobalt2-vim-customized'

" mark greek questionmarks
Plugin 'sterereo/semicolon-rescue'

" better bracket matching
Plugin 'tmhedberg/matchit'

" auto close brakctes
Plugin 'jiangmiao/auto-pairs'

" YCM autocomplete
Plugin 'rdnetto/YCM-Generator'

" doxygen helper
Plugin 'vim-scripts/DoxygenToolkit.vim'

" html support
Plugin 'mattn/emmet-vim'

" html close tags
Plugin 'alvan/vim-closetag'

if has("python")
    " .md preview, requires python
    Plugin 'joedicastro/vim-markdown-extra-preview'
endif

" general beautifier
Plugin 'Chiel92/vim-autoformat'

" show file tree
Plugin 'scrooloose/nerdtree'

" show git status in file tree
Plugin 'Xuyuanp/nerdtree-git-plugin'

" show git changes in file
Plugin 'airblade/vim-gitgutter'

" extended latex support
Plugin 'vim-latex/vim-latex'

" german spell checking
Plugin 'yowidin/vim-german-spell'

" generate c++ source files from header files
Plugin 'vim-scripts/h2cppx'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" all lower case search term => case insensitive, else case sensitive
set ignorecase
set smartcase

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set showmode		" display current mode
set incsearch		" do incremental searching
set wildmenu        " show available commands in command mode

map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif

set expandtab
set tabstop=8
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

" add 256 color support
set t_Co=256

" set colorscheme
colorscheme cobalt2

" don't confirm for extra config
let g:ycm_confirm_extra_conf = 0

" linenums
set nu

" /// comments for Doxygen
let g:DoxygenToolkit_commentType = "C++"

" relative linenumbers
set relativenumber

" allow YCM for markdown and similar files.
let g:ycm_filetype_blacklist = {}

" NERDTree on the right
let g:NERDTreeWinPos = "right"  

" .cc as file extension for c++ source files
let g:h2cppx_postfix = 'cc'
" point h2cppx to python2
let g:h2cppx_python_path = '/usr/bin/python2'

" jk to exit insert mode
imap jk <Esc>

