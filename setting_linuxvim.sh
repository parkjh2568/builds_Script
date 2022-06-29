#!/bin/bash

mkdir -p ~/.vim/pack/themes/start
cd ~/.vim/pack/themes/start
git clone https://github.com/dracula/vim.git dracula

cd
echo '

set nu
set mouse=a
set autoindent
set ts=4
set sts=4
set cindent
set laststatus=2
set shiftwidth=4
set showmatch
set smartcase
set smarttab
set smartindent
set ruler

packadd! dracula
syntax enable
let g:dracula_colorterm = 0
colorscheme dracula' >> .vimrc
