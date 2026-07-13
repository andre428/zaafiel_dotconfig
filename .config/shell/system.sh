#!/bin/sh

# ====================
# SYSTEM - Arch/Pacman
# ====================
alias pacup='sudo pacman -Syyu'                 # Update system
alias pacin='sudo pacman -S'                    # Install package
alias pacre='sudo pacman -Rns'                  # Remove package + deps
alias pacro='sudo pacman -Rns $(pacman -Qtdq)'  # Remove orphans
alias paclf='pacman -Ql'                        # List package files
alias pacmir='sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'  # Update mirrors

alias vicon='cd .config/nvim && nvim .'

# ====================
# CONDITIONAL ALIASES
# ====================
# Better cat (if bat is installed)
if command -v bat &> /dev/null; then
    alias cat='bat'
    alias catp='bat --paging=never'
fi

# Better ls (if exa is installed)
if command -v exa &> /dev/null; then
    alias ls='exa -a --group-directories-first'
    alias ll='exa -lah --group-directories-first'
    alias lx='exa -lXB'
    alias tree='exa --tree'
fi

# Better find (if fd is installed)
if command -v fd &> /dev/null; then
    alias find='fd'
fi

# Better grep (if ripgrep is installed)
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# ====================
# SYSTEM - General
# ====================
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) && paccache -r'

alias vi='nvim'
alias v.='nvim .'

open() {
  xdg-open "$1" >/dev/null 2>&1 &
}

alias n='nnn -P p'

alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ====================
# NAVIGATION
# ====================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cat='bat'
mkcd() { mkdir -pv "$1" && cd "$1"; }

# ====================
# LS VARIANTS
# ====================
alias lsd='ls -l | grep "^d"'               # List only directories
alias lsf='ls -la | grep -v "^d"'            # List only files

# Arch first setup:
# sudo pacman -S bat exa ripgrep fd fzf htop ncdu tree reflector
