#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# -------------[ Envinroment ]-------------
HISTCONTROL='ignoredups'
HISTSIZE=5000
HISTFILESIZE=5000

pick_default_editor(){
    for editor in nvim vim vi; do
        if command -v "$editor" >/dev/null 2>&1; then
            echo "$editor"
            return 0
        fi
    done
    echo "nano"
}
export EDITOR=$(pick_default_editor)
export VISUAL="$EDITOR"
export PAGER=less
export PATH="$PATH:~/.local/bin/"

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

which fdfind &> /dev/null;
if [[ $? -eq 0 ]]; then
    alias fd='fdfind'
fi

which batcat &> /dev/null;
if [[ $? -eq 0 ]]; then
  alias bat='batcat'
fi

which eza &> /dev/null;
if [[ $? -eq 0 ]]; then
  alias le="eza -l --icons --tree --git --git-ignore --short-nix --group-directories-last"
fi

# -------------[ Eval Tools ]-------------
which zoxide &> /dev/null;
if [[ $? -eq 0 ]]; then
    eval "$(zoxide init bash --cmd cd)"
fi

which jj &> /dev/null;
if [[ $? -eq 0 ]]; then
    source <(jj util completion bash)
fi

which fzf &> /dev/null;
if [[ $? -eq 0 ]]; then
    eval "$(fzf --bash)"

    which fd &> /dev/null;
    if [[ $? -eq 0 ]]; then
        export FZF_DEFAULT_COMMAND="fd --type f"
    fi

    which_cat='cat'
    which bat &> /dev/null;
    if [[ $? -eq 0 ]]; then
        which_cat='bat'
    fi

    export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --preview '"$which_cat" -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(|hidden|)'"

    export FZF_DEFAULT_OPTS=" \
        --border top \
        --layout reverse \
        --color=bg+:#414559,bg:#0e1419,spinner:#F2D5CF,hl:#E78284 \
        --color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
        --color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
        --color=selected-bg:#51576D \
        --color=border:#737994,label:#C6D0F5"
fi


# -------------[ Prompt  PS1]-------------
[[ -f ~/.config/bash/prompt.sh ]] && source ~/.config/bash/prompt.sh
