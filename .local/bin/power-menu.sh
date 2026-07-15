#!/usr/bin/env bash

choice=$(
printf " Lock\n Suspend\n󰜉 Logout\n Reboot\n Power Off" |
rofi -dmenu \
    -i \
    -p "Power"
)

case "$choice" in
    " Lock")
        pidof hyprlock >/dev/null || hyprlock
        ;;

    " Suspend")
        pidof hyprlock >/dev/null || hyprlock
        sleep 1
        systemctl suspend
        ;;

    "󰜉 Logout")
        hyprctl dispatch exit
        ;;

    " Reboot")
        systemctl reboot
        ;;

    " Power Off")
        systemctl poweroff
        ;;
esac
