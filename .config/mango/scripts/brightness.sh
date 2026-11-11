#!/usr/bin/env bash

case "$1" in
    up)
        swayosd-client --brightness raise
        ;;
    down)
        swayosd-client --brightness lower
        ;;
    kbd-up)
        swayosd-client --device="hp::kbd_backlight" --brightness raise
        ;;
    kbd-down)
        swayosd-client --device="hp::kbd_backlight" --brightness lower
        ;;
esac
