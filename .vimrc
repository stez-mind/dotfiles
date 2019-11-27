""""""""""""""""""""""""
" Plug configuration
""""""""""""""""""""""""

if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Generic
Plug 'tpope/vim-sensible'
Plug 'djoshea/vim-autoread'
Plug 'vim-scripts/EasyGrep'
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'vim-scripts/minibufexpl.vim'
Plug 'vim-scripts/The-NERD-tree'
Plug 'vim-scripts/taglist.vim'
Plug 'vim-scripts/UltiSnips'
Plug 'honza/vim-snippets'

" Appereance
Plug 'vim-airline/vim-airline'
Plug 'KabbAmine/vullScreen.vim'
Plug 'vim-scripts/ShowTrailingWhitespace'
Plug 'dracula/vim', { 'as': 'dracula' }

" C/C++
Plug 'vim-scripts/a.vim'
Plug 'ycm-core/YouCompleteMe'
Plug 'bfrg/vim-cpp-modern'
Plug 'vivien/vim-linux-coding-style'

" Other languages
Plug 'plasticboy/vim-markdown'
Plug 'elzr/vim-json'
Plug 'sbl/scvim', { 'for' : 'sclang' }
Plug 'gmoe/vim-faust', { 'for' : 'faust' }

call plug#end()

""""""""""""""""""""""""
" General config
""""""""""""""""""""""""

set nocompatible
if has('mouse')
    set mouse=a
endif

set nu
set ignorecase
set showcmd
set showmode
set visualbell
set smartindent
set wildignore=*.swp,*.bak,*.pyc,*.class
set nowrap
set nowb

set noswapfile
set nobackup
set nowritebackup
set hidden

set shiftwidth=4
set tabstop=4
set expandtab

filetype plugin indent on

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
au!

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

augroup END

" Use CTRL+C clipboard in X11
set clipboard=unnamedplus


""""""""""""""""""""""""
" Key remapping
""""""""""""""""""""""""
imap jj <Esc>

" CTRL-X and SHIFT-Del are Cut
vnoremap <C-X> "+x

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "*y
vnoremap <C-Insert> "*y

" SHIFT-Insert are Paste
map <S-Insert>		"*p

" Use CTRL-S for saving, also in Insert mode
noremap <C-S>		:update<CR>
vnoremap <C-S>		<C-C>:update<CR>
inoremap <C-S>		<C-O>:update<CR>

" CTRL-Y is Redo (although not repeat); not in cmdline though
noremap <C-Y> <C-R>
inoremap <C-Y> <C-O><C-R>

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G
onoremap <C-A> <C-C>gggH<C-O>G
snoremap <C-A> <C-C>gggH<C-O>G
xnoremap <C-A> <C-C>ggVG

" Scroll other windo with Alt+movement
nmap <a-j> <c-w>w<c-d><c-w>w
nmap <a-k> <c-w>w<c-u><c-w>w

" Activate / disable MiniBufExplorer with F3
map <F3> :TMiniBufExplorer<CR>

""""""""""""""""""""""""
" Appearance
""""""""""""""""""""""""

syntax on
set hlsearch

" set termguicolors

if has("gui_running")
    set guifont=Inconsolata\ 14
    set guioptions-=m
    set guioptions-=T
    command! Bigger  :let &guifont = substitute(&guifont, '\d\+$', '\=submatch(0)+1', '')
    command! Smaller :let &guifont = substitute(&guifont, '\d\+$', '\=submatch(0)-1', '')
    set columns=999
    set lines=999
    set background=dark
    colorscheme dracula
else
    set t_Co=256
    set background=dark
    colorscheme dracula
    if exists("+lines")
        set lines=50
    endif
    if exists("+columns")
        set columns=100
    endif
endif

" Folding options

set foldmethod=indent
set foldlevel=2
set nofoldenable


""""""""""""""""""""""""""""""""""""
" Plugin-specific configuration    "
""""""""""""""""""""""""""""""""""""

" Linux Coding Style paths
let g:linuxsty_patterns = [ "/linux/", "/kernel/" ]

" Clang Completion
let g:clang_library_path = '/usr/lib/llvm-6.0/lib/libclang-6.0.so'

let g:UltiSnipsExpandTrigger="<shift-tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1

nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>

" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'


" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" NERDtree & TList window width
let g:NERDTreeWinSize=20
let g:Tlist_WinWidth=20

" Dracula colorscheme
let g:dracula_italic = 1

