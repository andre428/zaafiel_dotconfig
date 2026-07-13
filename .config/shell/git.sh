#!/bin/sh

# ====================
# Git Shortcuts
# ====================
alias gis='git status'
alias gia='git add .'
alias gc='git commit -m'
alias gil='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all'
alias gif='git diff'
alias gremote='git remote -v'

# Useful git functions
function gac() { git add . && git commit -m "$1"; }
function gacp() { git add . && git commit -m "$1" && git push; }
function gclone() { git clone "$1" && cd "$(basename "$1" .git)"; }
