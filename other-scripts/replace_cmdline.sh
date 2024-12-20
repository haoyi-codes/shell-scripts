#!/bin/sh

# Script Name: replace_cmdline.sh
# File Path: <git_root>/replace_cmdline.sh
# Description: Replace kernel cmdline parameters.

# Copyright (c) 2024 Aryan
# SPDX-Licence-Identifier: BSD-3-Clause

# Version: 1.0.1

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

# Default CMDLINE parameters
delta_cmd_line="root=PARTUUID=<root_partuuid> nvidia_drm.fbdev=1 nosmt=force quiet"
kotori_cmd_line="rootfstype=bcachefs root=UUID=<root_uuid> nosmt=force intel_iommu=on quiet"

# Replace the CMDLINE parameters with the default ones.
find "./configs/delta/" -type f -exec sed -i "s/^CONFIG_CMDLINE=.*/CONFIG_CMDLINE=\"${delta_cmd_line}\"/" {} + \
    || { echo "${red}Error replacing delta command line parameters.${nc}"; exit 1; }

find "./configs/kotori/" -type f -exec sed -i "s/^CONFIG_CMDLINE=.*/CONFIG_CMDLINE=\"${kotori_cmd_line}\"/" {} + \
    || { echo "${red}Error replacing kotori command line parameters.${nc}"; exit 1; }

echo "${green}Successfully replaced command line parameters!${nc}"
