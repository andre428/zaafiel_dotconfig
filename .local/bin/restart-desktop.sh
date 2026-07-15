#!/usr/bin/env bash

pkill -x waybar
pkill -x mako

sleep 0.2

waybar >/dev/null 2>&1 &
mako >/dev/null 2>&1 &
