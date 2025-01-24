#!/bin/sh

# Script Name: shot.sh
# Script Path: /usr/local/bin/shot
# Description: Simple screenshot script using grimp + slurp or maim.

# Copyright (c) 2024 Aryan
# SPDX-License-Identifier: BSD-3-Clause

# Version: 1.0.2

# Colors
green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'

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

# Default image directory
image_directory="${HOME}/media/images/screenshots/"

mkdir -p "${image_directory}"

clipboard() {
    tmp_file="$(mktemp "/tmp/shot-XXXX")"

    if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
        grim -g "$(slurp -b '#00000000')" "${tmp_file}" || { echo "${red}Error taking screenshot.${nc}"; exit 1; }
        strip_meta_data
        cat "${tmp_file}" | wl-copy || { echo "${red}Error copying to clipboard.${nc}"; exit 1; }
        rm -f "${tmp_file}"
    else
        maim -s "${tmp_file}" || { echo "${red}Error taking screenshot.${nc}"; exit 1; }
        strip_meta_data
        cat "${tmp_file}" | xclip -sel clipboard -t image/png || { echo "${red}Error copying to clipboard.${nc}"; exit 1; }
        rm -f "${tmp_file}"
    fi

    echo "${green}Saved image to clipboard.${nc}"
}

default() {
    image_name

    if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
        grim -g "$(slurp -b '#00000000')" "${image_directory}/${image_name}" || { echo "${red}Error taking screenshot.${nc}"; exit 1; }
        strip_meta_data
    else
        maim -s "${image_directory}/${image_name}" || { echo "${red}Error taking screenshot.${nc}"; exit 1; }
        strip_meta_data
    fi

    echo "${green}Saved image to ${image_directory}/${image_name}.${nc}"
}

fullscreen() {
    image_directory="${image_directory}/archived/"
    image_name="$(date +%y-%m-%d-%H-%M-%S-%2N).png"

    mkdir -p "${image_directory}"

    if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
        grim -o ${m1} "${image_directory}/${image_name}" || { echo "${red}Error saving screenshot.${nc}"; exit 1; }
        strip_meta_data
    else
        maim "${tmp_file}" || { echo "${red}Error taking screenshot.${nc}"; exit 1; }
        strip_meta_data
    fi

    echo "${green}Saved image to ${image_directory}/${image_name}.${nc}"
}

image_name() {
    if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
        image_name="$(echo "" | bemenu --fn 'monospace 10' --tb '#005577' --tf '#ffffff' --hf '#ffffff' -p "Please enter the image name")"
    else
        image_name="$(echo "" | dmenu --fn 'monospace 10' --tb '#005577' --tf '#ffffff' --hf '#ffffff' -p "Please enter the image name")"
    fi

    if echo "$image_name" | grep -q '/'; then
        echo "${red}Creating new directories are not allowed.${nc}"
        exit 1
    fi

    # If the image does not have an extension append .png
    if [ "${image_name##*.}" != "png" ]; then
        image_name="${image_name}.png"
    fi
}

pastebin() {
    tmp_file="$(mktemp "/tmp/shot-XXXX")"

    if [ "${XDG_SESSION_TYPE}" = "wayland" ]; then
        grim -g "$(slurp -b '#00000000')" "${tmp_file}" || { echo "${red}Error taking screenshot.${nc}"; exit 1; }
        strip_meta_data
        curl -F"file=@${tmp_file}" https://0x0.st | wl-copy
        rm -f "${tmp_file}"
    else
        maim -s "${tmp_file}" || { echo "${red}Error taking screenshot.${nc}"; exit 1; }
        strip_meta_data
        curl -F"file=@${tmp_file}" https://0x0.st | xclip
        rm -f "${tmp_file}"
    fi

    echo "${green}Uploaded image to pastebin.${nc}"
}

prompt() {
    echo "Usuage: $0 [OPTION]
    By default shot will prompt for an image name and saves the region you have screenshotted to the default screenshot directory. \n
            -f, --fullscreen    Take a fullscreen screenshot to save in the default screenshot directory.
            -p, --pastebin      Upload screenshot to a pastebin and copy the link to clipboard.
            -c, --clipboard     Copy the image to clipboard."
}

strip_meta_data() {
    if [ "${1}" = "-c" ] || [ "${1}" = "--clipboard" ] || [ "${1}" = "-p" ] || [ "${1}" = "--pastebin" ]; then
        exiftool -all= -overwrite_original_in_place "${tmp_file}" > /dev/null 2>&1 || { echo "${red}Can't strip metadata from image ${tmp_file}.${nc}"; }
    else
        exiftool -all= -overwrite_original_in_place "${image_directory}/${image_name}" > /dev/null 2>&1 || { echo "${red}Can't strip metadata from image ${image_directory}/${image_name}.${nc}"; }
    fi

    echo "${green}Successfuly stripped metadata.${nc}"
}

case "${1}" in
    "") default ;;
    -f|--fullscreen) fullscreen ;;
    -p|--pastebin) pastebin ;;
    -c|--clipboard) clipboard ;;
    *) prompt ;;
esac
