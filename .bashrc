#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for file in ~/.config/shell/*.sh; do
    [ -f "$file" ] && . "$file"
done

PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"
eval "$(fzf --bash)"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env"

export NNN_FIFO=/tmp/nnn.fifo
export NNN_PLUG='f:finder;o:open;p:preview-tui'
export NNN_OPENER=xdg-open
