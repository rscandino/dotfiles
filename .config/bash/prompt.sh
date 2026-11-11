#!/bin/bash

### Setup
config() {
    # Define prompt segments
    declare -ag segments=(error identity path vcs nix nvim prompt)
    declare -ag dynamics=(error identity vcs nix nvim)

    # Define custom colors
    declare -g color_error="#EC6A88"
    declare -g color_primary="#f5992e"
    declare -g color_secondary="#785cea"
    declare -g color_neutral="#5f5f87"
    declare -g color_vcs="#87E58E"
    declare -g color_nix="#00DFDF"
    declare -g color_global

    # Define main color
    if is_root; then
        color_global=$color_secondary
    else
        color_global=$color_primary
    fi

    # Define prompt variables
    PS1=""
    PS2="→ "
    PROMPT_DIRTRIM=2
}

init() {
    for segment in "${segments[@]}"; do
        local renderer="render_$segment"

        # Skip segments without renderers
        if ! declare -F "$renderer" > /dev/null; then continue; fi

        if [[ "${dynamics[*]}" == *"$segment"* ]]; then
            # Evaluate every time
            PS1+="\$($renderer)"
        else
            # Evaluate only once
            PS1+="$($renderer)"
        fi
    done
}

### Renderers
render_error() {
    local cmd_status=$?
    local label

    if ! is_error "$cmd_status"; then
       return 1;
    fi

    label="$cmd_status"
    make_label "($label) " "$color_error";
}

render_identity() {
    local label

    if is_ssh; then
        label="ssh://$USER@$HOSTNAME:"
    elif is_su; then
        label="$USER@$HOSTNAME:"
    elif is_vcs; then
        label="[$(get_vcs_project)]"
    else
        label="${HOSTNAME%%.*}:"
    fi

    label="\001\033[1m\002$label\001\033[0m\002"
    make_label "$label "
}

render_path() {
    local label="\w"

    # Rendering logic
    printf "%s" "$label "
}

render_vcs() {
    local label="" out
    local is_git=0 is_jj=0

    git rev-parse --is-inside-work-tree >/dev/null 2>&1 && is_git=1
    jj root --ignore-working-copy >/dev/null 2>&1 && is_jj=1

    # Not in any repository
    (( is_git || is_jj )) || return 1

    if (( is_git )); then
        out=$(git symbolic-ref --short -q HEAD 2>/dev/null \
            || git rev-parse --short HEAD 2>/dev/null)
        [[ -n $out ]] && label="git/$out"
    fi

    if (( is_jj )); then
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

    # Safe print
    [[ -n $label ]] && printf "%s" "$(make_label "($label)" "$color_vcs")"
}

render_nvim() {
    [[ -n "$NVIM" ]] || return 1
    printf "%s " "$(make_label "(nvim)" "$color_neutral")"
}

render_nix() {
    local label=""

    if [[ -z ${IN_NIX_SHELL:-} && -z ${DEVENV_SHELL:-} \
          && $PATH != /nix/store/* ]]; then
        return 1
    fi

    label=${DEVENV_SHELL:-}
    if [[ -z $label && -n ${IN_NIX_SHELL:-} && ${name:-} != nix-shell ]]; then
        label=${name:-}
    fi

    printf "%s" "$(make_label "(nix${label:+/$label})" "$color_nix")"
}

render_prompt() {
    local label="$"

    [[ $is_root ]] || label="#"

    # Use bold label
    label="\001\033[1m\002$label\001\033[0m\002"

    printf "%s " "$(make_label "$label")"
}

### Helpers

hex_to_ansi() {
    local hex=${1#\#}
    local include_bg=${2:-false}

    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    if $include_bg; then
        printf "30;48;2;%s;%s;%s" "$r" "$g" "$b"
    else
        printf "2;%s;%s;%s" "$r" "$g" "$b"
    fi
}

make_label() {
    local content=$1
    local color=${2:-$color_global}

    # Prevent empty content
    if [[ -z $content ]]; then return 1; fi

    printf "\001\033[38;%sm\002" "$(hex_to_ansi "$color")"
    printf "%b" "$content"
    printf "\001\033[0m\002"
}


### Predicates

is_root() { [[ $EUID -eq 0 ]]; }
is_su() { [[ -n $LOGNAME && $USER != "$LOGNAME" ]]; }
is_ssh() { [[ -n "$SSH_CLIENT" ]]; }
is_error() { [[ $1 -ne 0 && $1 -ne 130 ]]; }
is_vcs() { [[ -n $(get_vcs_project) ]];}

# Get top-level repository name
get_vcs_project() {
    local root

    if command -v jj > /dev/null 2>&1 \
       && root=$(jj root --ignore-working-copy 2>/dev/null); then
        printf "%s" "${root##*/}"
        return 0
    fi

    if command -v git > /dev/null 2>&1 \
       && root=$(git rev-parse --show-toplevel 2>/dev/null); then
        printf "%s" "${root##*/}"
        return 0
    fi

    return 1
}

### Initialize

config && init
