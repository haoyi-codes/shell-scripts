#!/bin/sh

# Script Name: copy_kernel_config.sh
# File Path: <kernel-configs-repo>/copy_kernel_config.sh
# Description: Copy kernel configuration file.

# Copyright (c) 2024 Aryan
# SPDX-Licence-Identifier: BSD-3-Clause

# Version: 2.1.0

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

system="${1}"

if [ -z "${system}" ]; then
    echo "${red}Invalid Option: ${1}${nc}"
    echo "Correct usage: ${0} [SYSTEM]"

    exit 1
fi

# Check if system is reachable.
echo "Checking if ${system} is pingable..."
ping -c 1 -W 1 "${system}" > /dev/null 2>&1 && echo "${green}Success!${nc}" || { echo "${red}${system} is not reachable.${nc}"; exit 1; }

# Check if we can access system via SSH.
echo "Checking if we can obtain ${system}'s via SSH..."
hostname=$(ssh ${system} hostname) || { echo "${red}Can not obtain hostname for ${system}.${nc}"; exit 1; }
echo "${green}Success!${nc}"

# Check if remote's hostname is the same as ${system}.
if [ "${hostname}" = "${system}" ]; then
    echo "${green}/etc/hostname file for ${system} says ${system}!${nc}"
else
    echo "${red}/etc/hostname file on ${system} does not match ${system}.${nc}"
    echo "${red}This could be because of an incorrect hosts configuration file on your current system.${nc}"

    exit 1
fi

# Test if remote has /usr/local/src/${system}/linux/.
src_path="/usr/local/src/"

ssh ${system} [ -d "${src_path}/${system}/linux/" ] || { echo "${red}${src_path}${system}/linux/ is not available. This script uses this directory to copy configuration files from.${nc}"; exit 1; }

# Allow user to select a kernel version they want to copy over.
echo "Available Linux kernels:"
ssh ${system} ls "${src_path}/${system}/linux/"

while true; do
    echo "Select a version:"
    read version

    if ssh ${system} [ -d "${src_path}/${system}/linux/${version}/" ]; then
        chosen_ver="${version}"

        break
    elif ssh ${system} [ -d "${src_path}/${system}/linux/linux-${version}/" ]; then
        chosen_ver="linux-${version}"

        break
    else
        echo "${red}Please choose a valid version.${nc}"
    fi
done

chosen_ver_path="${src_path}/${system}/linux/${chosen_ver}/"

echo "${green}You have selected ${chosen_ver}.${nc}"

# Copy over configuration file to ./configs/${system}/
linux_config="$(ssh ${system} cat \"${chosen_ver_path}/.config\")"
linux_ver="$(echo "${linux_config}" | awk '/# Linux\/x86/ { print $3 }')"
local_ver="$(echo "${linux_config}" | grep "^CONFIG_LOCALVERSION" | sed -e 's/"//g' -e 's/^CONFIG_LOCALVERSION=-//')"
full_linux_ver="${linux_ver}-${local_ver}"

rsync -ahuq "${system}:${chosen_ver_path}/.config" "./configs/${system}/${full_linux_ver}" || { echo "${red}Error copying ${full_linux_ver} to configs/${system}/.${nc}"; exit 1; }

# Replace command line parameters.
./replace_cmdline.sh || { echo "${red}Error replacing command line parameters.${nc}"; exit 1; }

echo "${green}Copied ${full_linux_ver} successfully! Exiting...${nc}"
