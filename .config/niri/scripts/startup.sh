#!/bin/bash

swayidle -w \
  timeout 300 'swaylock -f' \
  timeout 600 'niri msg action power-off-monitors' \
  before-sleep 'swaylock -f' &

swayosd-server &
wpaperd -d
# swaybg -m fill -i /home/riccardo/Backgrounds/wallpapers/wallhaven-9o2w9k.png &
