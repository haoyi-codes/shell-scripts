#!/bin/sh

# Script Name: set-wallpaper.sh
# Script Path: /usr/local/bin/set-wallpaper
# Description: A simple script that sets the wallpaper.

# Copyright (c) 2024 Aryan
# SPDX-License-Identifier: BSD-3-Clause

# Version: 2.0.0

# Exit if the user is root.
if [ "$(id -u)" -eq 0 ]; then
    if [ -e "/usr/bin/uu-basename" ]; then
        echo "${red}$(uu-basename ${0}): please do not run as root.${nc}"
    else
        echo "${red}$(basename ${0}): please do not run as root.${nc}"
    fi

    exit 1
fi

# Monitors
m1="DP-1"
default_wallpaper="/usr/local/share/wallpapers/default_wallpaper.png"
wallpaper_path="${HOME}/media/images/wallpapers/selected/"

# Check if user is in a wayland session.
if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
    # Kill running instances of wallpapers.
    swaybg_pids=$(ps aux | grep "$(whoami)" | grep "swaybg" | grep -v "grep" | awk '{print $2}' | xargs)
    mpvpaper_pids=$(ps aux | grep "$(whoami)" | grep "mpvpaper" | grep -v "grep" | awk '{print $2}' | xargs)
    
    [ -n "${swaybg_pids}" ] && kill -15 ${swaybg_pids}
    [ -n "${mpvpaper_pids}" ] && kill -15 ${mpvpaper_pids}
fi

default() {
    # If we don't have a specific image, use the default.
    if [ -e "${wallpaper_path}/01.png" ]; then
        wallpaper="${wallpaper_path}/01.png"
    else
        wallpaper="${default_wallpaper}"
    fi

    # Set the wallpaper.
    if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
        swaybg -o ${m1} -i "${wallpaper}" -m fill > /dev/null 2>&1 &
    else
        xwallpaper --zoom "${wallpaper}"
    fi
}

none() {
    if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
        swaybg -o ${m1} -c "#000000" -m solid_color > /dev/null 2>&1 &
    else
        xwallpaper --clear
    fi
}

# Process flags
case "${1}" in
    -n|--none) none ;;
    "") default ;;
    *)
        echo "Invalid Option: ${1}" 
        echo "Correct Usage: ${0} [OPTIONS]"
        echo "Available Options: -n|--none"

        exit 1
    ;;
esac
