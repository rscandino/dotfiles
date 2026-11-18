#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# -------------[ Environment ]-------------
HISTCONTROL='ignoredups'
HISTSIZE=5000
HISTFILESIZE=5000

# Default editor
for EDITOR in nvim vim vi nano; do
    type -P "$EDITOR" >/dev/null && break
done
export EDITOR
export VISUAL="$EDITOR"
export PAGER=less

# Add .local/bin to PATH
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$PATH:$HOME/.local/bin" ;;
esac

# Support colors in man pages
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;33;44m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;1;32m'
export LESS_TERMCAP_mr=$'\e[7m'
export LESS_TERMCAP_mh=$'\e[2m'
export LESS_TERMCAP_ZN=$'\e[74m'
export LESS_TERMCAP_ZV=$'\e[75m'
export LESS_TERMCAP_ZO=$'\e[73m'
export LESS_TERMCAP_ZW=$'\e[75m'

# -------------[ Shell/Bash Options ]-------------
shopt -s cdspell
shopt -s checkwinsize # on by default
shopt -s dirspell 2>/dev/null || true

# -------------[ Aliases ]-------------
alias ls='ls --color=auto -p'
alias ll='ls --color=auto -p -lh'
alias la='ls --color=auto -p -lha'

alias grep='grep --color=auto'
alias hl='rg --passthru'

alias ..='echo "cd .."; cd ..'
alias cd..='echo "cd .."; cd ..'

# Real binary names (aliases are not visible to fzf's child shells)
_fd= _bat=
if   type -P fd      >/dev/null; then _fd=fd
elif type -P fdfind  >/dev/null; then _fd=fdfind; alias fd='fdfind'; fi
if   type -P bat     >/dev/null; then _bat=bat
elif type -P batcat  >/dev/null; then _bat=batcat; alias bat='batcat'; fi

if type -P eza >/dev/null; then
    alias le="eza -l --icons --tree --git --git-ignore --short-nix --group-directories-last"
fi

# -------------[ Eval Tools (cached) ]-------------
# `tool init`/`completion` output is cached in ~/.cache/bash and re-generated
# only when the binary is newer than the cache. If a tool is upgraded and its
# binary mtime doesn't change (e.g. nix), run: rm -rf ~/.cache/bash
_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/bash

__which() {     # PATH lookup without forking; result in REPLY
    local d IFS=:
    for d in $PATH; do
        [[ -x $d/$1 && ! -d $d/$1 ]] && { REPLY=$d/$1; return 0; }
    done
    return 1
}

__source_cached() {     # __source_cached NAME CMD [ARGS...]
    local name=$1 f; shift
    f=$_cache_dir/$name.bash
    __which "$1" || return 1
    if [[ ! -s $f || $REPLY -nt $f ]]; then
        mkdir -p "$_cache_dir" && "$@" >"$f.tmp" 2>/dev/null && mv -f "$f.tmp" "$f" \
            || { rm -f "$f.tmp"; return 1; }
    fi
    source "$f"
}

__source_cached zoxide zoxide init bash --cmd cd
__source_cached jj     jj util completion bash

if __source_cached fzf fzf --bash; then
    [[ -n $_fd ]] && export FZF_DEFAULT_COMMAND="$_fd --type f"

    if [[ -n $_bat ]]; then
        _preview="$_bat -n --color=always {}"
    else
        _preview="cat -n {}"
    fi
    export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --preview '$_preview'
    --bind 'ctrl-/:change-preview-window(|hidden|)'"
    unset _preview

    export FZF_DEFAULT_OPTS=" \
        --border top \
        --layout reverse \
        --color=bg+:#414559,bg:#0e1419,spinner:#F2D5CF,hl:#E78284 \
        --color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
        --color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
        --color=selected-bg:#51576D \
        --color=border:#737994,label:#C6D0F5"
fi
unset _fd _bat

# -------------[ Prompt PS1 ]-------------
[[ -f ~/.config/bash/prompt.sh ]] && source ~/.config/bash/prompt.sh
