" No need to be compatible with old vi
set nocompatible
" Automatically detect file types and load their corresponding settings/indentation rules
filetype plugin indent on
" Enable syntax highlighting
syntax on
" Set a dark background
set background=dark
" Set a color scheme
colorscheme solarized
" Display cursor position
set ruler
" Display line numbers
set number
" Display relative line numbers
set relativenumber
" Always display status line
set laststatus=2
" Hide mode from status line
set noshowmode
" Needed for displaying vim-devicons
set encoding=utf-8
" Disable arrow keys.
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
" NERDTreee
" Show hidden files in explorer
let NERDTreeShowHidden=1
" Close NERDTree when closing the file
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Setup NERDTree to open with Ctrl+n
map <C-n> :NERDTreeToggle<CR>
" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0