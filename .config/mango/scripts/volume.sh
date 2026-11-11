#!/usr/bin/env bash

case "$1" in
    up)
        swayosd-client --output-volume raise
        ;;
    down)
        swayosd-client --output-volume lower
        ;;
    mute)
        swayosd-client --output-volume mute-toggle
        # Sincronizza il LED hardware dello speaker
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
            brightnessctl --device='hda::mute' set 1
        else
            brightnessctl --device='hda::mute' set 0
        fi
        ;;
    mic-mute)
        swayosd-client --input-volume mute-toggle
        # Sincronizza il LED hardware del microfono
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
            brightnessctl --device='hda::micmute' set 1
        else
            brightnessctl --device='hda::micmute' set 0
        fi
        ;;
esac
