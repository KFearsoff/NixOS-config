{ pkgs, ... }:

{
  enable = true;
  package = pkgs.neovim-nightly;
  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;

  plugins = with pkgs.vimPlugins; [
  vim-airline
  vim-nix
    dracula-vim
    nvim-lspconfig 
    nvim-cmp
  ];

  extraConfig = ''
    set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
    set clipboard=unnamedplus
    syntax on
    colorscheme dracula
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    set nocompatible
    set showmatch
    set ignorecase
    set mouse=v
    set hlsearch
    set incsearch
    set tabstop=2
    set softtabstop=2
    set expandtab
    set shiftwidth=2
    set autoindent
    set number
    set wildmode=longest,list
    set cc=80
    filetype plugin indent on
    set mouse=a
    filetype plugin on
    set cursorline

    lua << EOF
    require'lspconfig'.rnix.setup{}
    '';
}
