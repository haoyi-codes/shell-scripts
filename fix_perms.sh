#!/bin/sh

# Script Name: fix_perms.sh
# Script Path: /usr/local/bin/fix_perms
# Description: Fix permissions for files and directories.

# Copyright (c) 2024 Reticent Admin
# SPDX-License-Identifier: BSD-3-Clause

# Version: 2.0.0+kotori

# Color configuration
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

# Set directory permissions to 770 and file permissions to 660.

## a00-s4-mmd
if [ "$(id -u)" -eq 1002 ]; then
    # images
    find "/nfs/media/images/" -type d ! -perm 770 -exec chmod 770 {} +
    find "/nfs/media/images/" -type f ! -perm 660 -exec chmod 660 {} +

    # music
    find "/nfs/media/music/" -type d ! -perm 770 -exec chmod 770 {} +
    find "/nfs/media/music/" -type f ! -perm 660 -exec chmod 660 {} +
fi

## qbittorrent
if [ "$(id -u)" -eq 534 ]; then
    # anime
    find "/nfs/media/anime/" -type d ! -perm 770 -exec chmod 770 {} +
    find "/nfs/media/anime/" -type f ! -perm 660 -exec chmod 660 {} +
    
    # movies
    find "/nfs/media/movies/" -type d ! -perm 770 -exec chmod 770 {} +
    find "/nfs/media/movies/" -type f ! -perm 660 -exec chmod 660 {} +
    
    # shows
    find "/nfs/media/shows/" -type d ! -perm 770 -exec chmod 770 {} +
    find "/nfs/media/shows/" -type f ! -perm 660 -exec chmod 660 {} +
fi
