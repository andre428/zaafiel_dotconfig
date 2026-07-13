#!/bin/sh

# ====================
# PYTHON
# ====================
alias pyvenv='python -m venv .venv'
alias pyvact='source venv/bin/activate'
alias pyvde='deactivate'
alias verm='rm -rf venv'

alias pyclean='find . -type d -name "__pycache__" -exec rm -r {} +'
