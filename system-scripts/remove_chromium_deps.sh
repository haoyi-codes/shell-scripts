#!/bin/sh

# Script Name: remove_chromium_deps.sh
# Script Path: /usr/local/sbin/remove_chromium_deps
# Description: Remove libexecinfo and musl-legacy-compat.

# Copyright (c) 2024 Aryan
# SPDX-License-Identifier: BSD-3-Clause

# Version: 2.0.0+kotori

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

# musl-legacy-compat
if [ -e "/usr/include/sys/cdefs.h" ]; then
    echo "${green}Removing cdefs.h.${nc}"
    rm "/usr/include/sys/cdefs.h"
else
    echo "${red}cdefs.h already removed.${nc}"
fi

if [ -e "/usr/include/sys/tree.h" ]; then
    echo "${green}Removing tree.h.${nc}"
    rm "/usr/include/sys/tree.h"
else
    echo "${red}tree.h already removed.${nc}"
fi

# libexecinfo
if [ -e "/usr/include/execinfo.h" ]; then
    echo "${green}Removing execinfo.h.${nc}"
    rm "/usr/include/execinfo.h"
else
    echo "${red}execinfo.h already removed.${nc}"
fi

if [ -e "/usr/lib/libexecinfo.so" ]; then
    echo "${green}Removing libexecinfo.so.${nc}"
    rm "/usr/lib/libexecinfo.so"
else
    echo "${red}libexecinfo.so already removed.${nc}"
fi

if [ -e "/usr/lib/libexecinfo.so.1" ]; then
    echo "${green}Removing libexecinfo.so.1.${nc}"
    rm "/usr/lib/libexecinfo.so.1"
else
    echo "${red}libexecinfo.so.1 already removed.${nc}"
fi

if [ -e "/usr/lib/libexecinfo.a" ]; then
    echo "${green}Removing libexecinfo.a.${nc}"
    rm "/usr/lib/libexecinfo.a"
else
    echo "${red}libexecinfo.a already removed.${nc}"
fi

if [ -e "/usr/lib/pkgconfig/libexecinfo.pc" ]; then
    echo "${green}Removing libexecinfo.pc.${nc}"
    rm "/usr/lib/pkgconfig/libexecinfo.pc"
else
    echo "${red}libexecinfo.pc already removed.${nc}"
fi
