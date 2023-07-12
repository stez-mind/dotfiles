set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Tidal stuff
let g:tidal_target = "terminal"
let g:tidal_boot = "/Users/stex/xug/tidalstuff/configs/BootTidal.hs"
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
let maplocalleader=","

