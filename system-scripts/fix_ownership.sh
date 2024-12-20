#!/bin/sh

# Script Name: fix_ownership.sh
# Script Path: /usr/local/sbin/fix_ownership
# Description: Fix ownership for files and directories.

# Copyright (c) 2024 Aryan
# SPDX-License-Identifier: BSD-3-Clause

# Version: 1.1.0+kotori

# Color configuration
green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'

# Exit if the user is not root.
if [ "$(id -u)" -ne 0 ]; then
    if [ -e "/usr/bin/uu-basename" ]; then
        echo "${red}$(uu-basename ${0}): must be superuser.${nc}"
    else
        echo "${red}$(basename ${0}): must be superuser.${nc}"
    fi

    exit 1
fi

# Set ownership to owner:group.

## images
chown -R a00-s4-mmd:media "/nfs/media/images/"

## music
chown -R a00-s4-mmd:music "/nfs/media/music/"

## qbittorrent
chown -R qbittorrent:media "/nfs/media/anime/"
chown -R qbittorrent:media "/nfs/media/movies/"
chown -R qbittorrent:media "/nfs/media/shows/"
