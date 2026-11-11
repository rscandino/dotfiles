#!/bin/sh

set +e

# # notify
# swaync -c ~/.config/mango/swaync/config.jsonc -s ~/.config/mango/swaync/style.css >/dev/null 2>&1 &

# wallpaper
swaybg -i /home/riccardo/Pictures/Wallpapers/wallhaven-mlo6my.png &
swayidle -w timeout 300 'swaylock -f -c 000000' timeout 600 'wlr-randr --output eDP-1 --off' resume 'wlr-randr --output edP-1 --on' &

# top bar
# mangobar -c ~/.config/mango/mangobar/config.jsonc -s ~/.config/mango/mangobar/style.css 2>&1 &

# Permission authentication
# Launch the LXQt Polkit agent in the background
lxqt-policykit-agent &

# change light value and volume value by swayosd-client in keybind
swayosd-server >/dev/null 2>&1 &
