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

# -------------[ Prompt  PS1]-------------
_prompt_command() {
        local user=$USER
        local host=${HOSTNAME%%.*}
        local pwd=${PWD/#$HOME/\~}
        [[ -n $SSH_CLIENT ]] && ssh='[ssh] '
        printf "\033]0;%s%s@%s:%s\007" "$ssh" "$user" "$host" "$pwd"
}

# updates tab/window title
PROMPT_COMMAND="_prompt_command${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# Set and retrieve color code
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

#
# Construct the prompt PS1
#
# [(exit code)] <user>: <cwd> (nix:shell) (git:branch) <$|#>

# Wrapp get color with raw \[ symbols for bash
__c() { printf '\001%s\002' "$(get_color "$1")"; }

# Remember the original PATH, exported so nested shells inherit it
export __BASE_PATH="${__BASE_PATH:-$PATH}"

# NVIM builtin shell false positive
[[ -n "$NVIM" ]] && __BASE_PATH="$PATH"

# NIX shell/develop optional module DEVSHELL_NAME must be specified in nix devShell
__nix_prompt() {
  local tag=""
  if [[ -n "$DEVSHELL_NAME" ]]; then
    tag="nix:$DEVSHELL_NAME"
  elif [[ -n "$IN_NIX_SHELL" ]]; then
    tag="nix"
  elif [[ "$PATH" != "$__BASE_PATH" && ":$PATH:" == *":/nix/store/"* ]]; then
    tag="nix"
  fi

  [[ -n $tag ]] && printf '%s%s(%s)%s' \
      "$(__c bold)" "$(__c cyan)" "$tag" "$(__c sgr0)"
}

# GIT optional module
__git_prompt() {
  local branch
  branch=$(git symbolic-ref --short -q HEAD 2>/dev/null \
        || git rev-parse --short HEAD 2>/dev/null) || return

  [[ -n $branch ]] && printf '%s%s(git:%s)%s' \
      "$(__c bold)" "$(__c green)" "$branch" "$(__c sgr0)"
}

# JJ versioning optional
command -v jj &>/dev/null && __HAVE_JJ=1

__in_jj_repo() {
  [[ -n $__HAVE_JJ ]] || return 1
  local d=$PWD
  while [[ -n $d ]]; do
    [[ -d $d/.jj ]] && return 0
    d=${d%/*}
  done
  [[ -d /.jj ]]
}

__jj_prompt() {
  __in_jj_repo || return 1

  local info
  info=$(jj log --no-graph --ignore-working-copy --color never -r @ \
      -T 'separate(" ",
            change_id.shortest(4),
            bookmarks,
            if(conflict, "×"),
            if(empty, "∅")
          )' 2>/dev/null) || return 1

  [[ -n $info ]] && printf '%s%s(jj:%s)%s ' \
      "$(__c bold)" "$(__c magenta)" "$info" "$(__c sgr0)"
}


# Global versioning
__vcs_prompt() {
  __jj_prompt && return
  __git_prompt
}

# exit code of last process
PS1='$(ret=$?;(($ret!=0)) && echo "\[$(get_color red)\]($ret) \[$(get_color sgr0)\]")'

# username (red for root)
PS1+='\[$(get_color )\]\[$(get_color bold)\]$(((UID==0)) && echo "\[$(get_color red)\]")\u@\h\[$(get_color bold)\]:'

# cwd
PS1+='\[$(get_color blu)\]\w '

# optional nix shell
PS1+='$(__nix_prompt)'

# optional git branch
PS1+='$(__vcs_prompt)'

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
