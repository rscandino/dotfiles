#!/bin/bash

# __fg VAR "#rrggbb"  -> VAR = truecolor foreground escape, readline-safe
__fg() {
    local hex=${2#\#}
    printf -v "$1" '\001\e[38;2;%d;%d;%dm\002' \
        "$((16#${hex:0:2}))" "$((16#${hex:2:2}))" "$((16#${hex:4:2}))"
}

# Find nearest .jj and .git roots from $PWD. Sets _jj_root / _git_root.
__find_vcs() {
    local d=$PWD
    _jj_root= _git_root=
    while :; do
        [[ -z $_jj_root  && -d $d/.jj ]] && _jj_root=$d
        [[ -z $_git_root && -e $d/.git ]] && _git_root=$d   # .git may be a file (worktree)
        [[ -n $_jj_root && -n $_git_root ]] && break
        [[ -z $d || $d == / ]] && break
        d=${d%/*}
    done
}

# Branch (or short hash) of $_git_root without running git. Result in REPLY.
__git_branch() {
    local gitdir=$_git_root/.git head
    if [[ -f $gitdir ]]; then
        { read -r head < "$gitdir"; } 2>/dev/null || return 1
        gitdir=${head#gitdir: }
        [[ $gitdir == /* ]] || gitdir=$_git_root/$gitdir
    fi
    { read -r head < "$gitdir/HEAD"; } 2>/dev/null || return 1
    if [[ $head == "ref: "* ]]; then
        REPLY=${head#ref: }
        REPLY=${REPLY#refs/heads/}
    else
        REPLY=${head:0:7}
    fi
}

__prompt_command() {
    local st=$? label out

    __find_vcs

    # --- error ---
    if (( st != 0 && st != 130 )); then
        _ps_error="$_c_error($st) $_c_reset"
    else
        _ps_error=
    fi

    # --- identity ---
    if [[ -n $_id_fixed ]]; then
        label=$_id_fixed
    elif [[ -n ${_jj_root:-$_git_root} ]]; then
        out=${_jj_root:-$_git_root}
        label="[${out##*/}]"
    else
        label="${HOSTNAME%%.*}:"
    fi
    _ps_identity="$_c_main$_c_bold$label$_c_reset "

    # --- vcs ---
    label=
    if [[ -n $_git_root ]] && __git_branch; then
        label="git/$REPLY"
    fi
    if [[ -n $_jj_root ]] && command -v jj >/dev/null; then
        out=$(jj log --no-graph --ignore-working-copy --color never -r @ -T '
            separate(" ",
                change_id.shortest(4),
                bookmarks,
                if(conflict, "conflict"),
                if(divergent, "divergent"),
                if(empty, "empty")
            )' 2>/dev/null)
        [[ -n $out ]] && label+="${label:+ }jj/$out"
    fi
    if [[ -n $label ]]; then
        _ps_vcs="$_c_vcs($label)$_c_reset "
    else
        _ps_vcs=
    fi

    # --- nix ---
    _ps_nix=
    if [[ -n ${IN_NIX_SHELL:-} || -n ${DEVENV_SHELL:-} || $PATH == /nix/store/* ]]; then
        label=${DEVENV_SHELL:-}
        if [[ -z $label && -n ${IN_NIX_SHELL:-} && ${name:-} != nix-shell ]]; then
            label=${name:-}
        fi
        _ps_nix="$_c_nix(nix${label:+/$label})$_c_reset "
    fi

    # --- nvim ---
    if [[ -n $NVIM ]]; then
        _ps_nvim="$_c_neutral(nvim)$_c_reset "
    else
        _ps_nvim=
    fi

    return "$st"   # keep $? intact for whatever hooks run after us
}

__prompt_init() {
    # Colors (computed once)
    __fg _c_error   "#EC6A88"
    __fg _c_vcs     "#9ece6a"
    __fg _c_nix     "#bb9af7"
    __fg _c_neutral "#5f5f87"
    if (( EUID == 0 )); then
        __fg _c_main "#f7768e"
    elif [[ -n $SSH_CLIENT ]]; then
        __fg _c_main "#E8EDA2"
    else
        __fg _c_main "#00DFDF"
    fi
    _c_bold=$'\001\e[1m\002'
    _c_reset=$'\001\e[0m\002'

    # Parts of the identity label that never change during a session
    _id_fixed=
    if [[ -n $SSH_CLIENT ]]; then
        _id_fixed="[ssh://] $USER@$HOSTNAME:"
    elif [[ -n $LOGNAME && $USER != "$LOGNAME" ]]; then
        _id_fixed="$USER@$HOSTNAME:"
    fi

    PS1='${_ps_error}${_ps_identity}\w ${_ps_vcs}${_ps_nix}${_ps_nvim}\$ '
    PS2='→ '
    PROMPT_DIRTRIM=2

    # Run first so we see the real $? of the last command (bash >= 4.4)
    if [[ ${PROMPT_COMMAND@a} == *a* ]]; then
        [[ " ${PROMPT_COMMAND[*]} " == *" __prompt_command "* ]] ||
            PROMPT_COMMAND=(__prompt_command "${PROMPT_COMMAND[@]}")
    else
        [[ ";$PROMPT_COMMAND;" == *";__prompt_command;"* ]] ||
            PROMPT_COMMAND="__prompt_command${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
}

__prompt_init
