#!/bin/sh

# Script Name: copy_scripts.sh
# Script Path: <git_root>/copy_scripts.sh
# Description: Copy shell scripts from PATH.

# Copyright (c) 2024 Aryan
# SPDX-License-Identifier: BSD-3-Clause

# Version: 2.0.0

mkdir -p "./system-scripts/"
mkdir -p "./other-scripts/"

# system-scripts

## sbin scripts
cp "/usr/local/sbin/firewall" "./scripts/firewall.sh"
cp "/usr/local/sbin/fix_ownership" "./scripts/fix_ownership.sh"
cp "/usr/local/sbin/remove_chromium_deps" "./scripts/remove_chromium_deps.sh"

## bin scripts
cp "/usr/local/bin/fix_perms" "./scripts/fix_perms.sh"
cp "/usr/local/bin/set_wallpaper" "./scripts/set_wallpaper.sh"
cp "/usr/local/bin/shot" "./scripts/shot.sh"

# Other scripts

## etc-configs
cp "../../linux/etc-configs/copy_etc_configs.sh" "./other-scripts/"

## kernel-configs
cp "../../linux/kernel-configs/copy_config.sh" "./other-scripts/"
cp "../../linux/kernel-configs/replace_cmdline.sh" "./other-scripts/"
