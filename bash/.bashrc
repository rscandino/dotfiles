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

# -------------[ Prompt  PS1]-------------
_prompt_command() {
        local user=$USER
        local host=${HOSTNAME%%.*}
        local pwd=${PWD/#$HOME/\~}
        [[ -n $SSH_CLIENT ]] && ssh='[ssh] '
        printf "\033]0;%s%s@%s:%s\007" "$ssh" "$user" "$host" "$pwd"
}
# updates tab/window title
PROMPT_COMMAND=_prompt_command

# set and retrieve color code
# takes one argument as 'case'; no arguments returns white code
get_color() {
    local h=${1:-0}
    case $h in
        sgr0) #reset colors
            echo $'\e[0m'
            ;;
        bold)
            echo $'\e[1m'
            ;;
        red)
            echo $'\e[31m'
            ;;
        green)
            echo $'\e[32m'
            ;;
        yellow)
            echo $'\e[33m'
            ;;
        blu)
            echo $'\e[34m'
            ;;
        magenta)
            echo $'\e[35m'
            ;;
        cyan)
            echo $'\e[36m'
            ;;
        *)
            echo $'\033[0;37m'
            ;;
    esac
}

# Construct the prompt PS1
# [(exit code)] <user>: <cwd> [git branch] <$|#>

# exit code of last process
PS1='$(ret=$?;(($ret!=0)) && echo "\[$(get_color red)\]($ret) \[$(get_color sgr0)\]")'

# username (red for root)
PS1+='\[$(get_color )\]\[$(get_color bold)\]$(((UID==0)) && echo "\[$(get_color red)\]")\u\[$(get_color bold)\]:'

# cwd
PS1+='\[$(get_color blu)\]\w '

# optional git branch
PS1+='$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "\[$(get_color sgr0)\]\[$(get_color)\](git:\[$(get_color green)\]$branch\[$(get_color)\]) ")'

# prompt character
PS1+='\[$(get_color)\]\$\[$(get_color sgr0)\] '

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
  alias le="eza -l --icons --tree --git"
fi

# -------------[ Eval Tools ]-------------
which zoxide &> /dev/null;
if [[ $? -eq 0 ]]; then
    eval "$(zoxide init bash --cmd cd)"
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
