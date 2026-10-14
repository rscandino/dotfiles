#!/bin/sh

TMUX_BIN="$(command -v tmux &> /dev/null || { echo 'tmux not found'; exit 1; })"
FUZZEL_BIN="$(command -v fuzzel &> /dev/null || { echo 'fuzzel not found'; exit 1; })"
FUZZEL_FONT='JetBrainsMono Nerd Font:size=16'

sessions="$("$TMUX_BIN" list-sessions -F '#{session_name}' &> /dev/null || true)"

menu="Create new session…\n$sessions"

choice="$(printf '%b' "$menu" | "$FUZZEL_BIN" --dmenu \
    -B 3 \
    -w 40 \
    -l 30 \
    -f "$FUZZEL_FONT" \
    -p 'Sessions: ' || true)"
[ -n "$choice" ] || exit 0

if [ "$choice" = "Create new session…" ]; then
    new_name="$(printf '' | "$FUZZEL_BIN" --dmenu \
        -B 3 \
        -w 40 \
        -f "$FUZZEL_FONT" \
        -p 'New session name: ' || true)"
    [ -n "$new_name" ] || exit 0
    session="$new_name"
    create=1
else
    session="$choice"
    create=0
fi

# Inside tmux: create (detached) if needed, then switch (NO exec on create)
if [ -n "${TMUX-}" ]; then
    if [ "$create" -eq 1 ] && ! "$TMUX_BIN" has-session -t "$session" 2>/dev/null; then
        "$TMUX_BIN" new-session -ds "$session"
    fi
    exec "$TMUX_BIN" switch-client -t "$session"
fi

# Outside tmux: one-terminal behavior
pkill -x st 2>/dev/null || true
sleep 0.1

if [ "$create" -eq 1 ]; then
    # create and attach
    exec st -e "$TMUX_BIN" new-session -s "$session"
else
    # attach existing
    exec st -e "$TMUX_BIN" attach -t "$session"
fi
