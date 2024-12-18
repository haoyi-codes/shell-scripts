#!/bin/sh

# Script Name: firewall.sh
# Script Path: /usr/local/sbin/firewall
# Description: Simple iptables/ip6tables firewall configuration.

# Copyright (c) 2024 Aryan
# SPDX-License-Identifier: BSD-3-Clause

# Version: 1.0.0+kotori

# Color configuration
green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'

# Exit if user is not root.
if [ "$(id -u)" -ne 0 ]; then
    if [ -e "/usr/bin/uu-basename" ]; then
        echo "${red}$(uu-basename ${0}): must be superuser.${nc}"
    else
        echo "${red}$(basename ${0}): must be superuser.${nc}"
    fi

    exit 1
fi

# IPV4

## Flush existing rules
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

## Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

## Allow lo
iptables -A INPUT -i lo -j ACCEPT

## Allow established/related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

## ICMP configuration
iptables -A INPUT -p icmp --icmp-type 3 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 11 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 12 -j ACCEPT
iptables -A INPUT -p tcp --syn --dport 113 -j REJECT --reject-with tcp-reset

## Allow ports

### LAN
iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp --dport 8384 -s 10.0.0.0/8 -j ACCEPT

## Deny internet connection for these users.

### x00-s4-games
iptables -A OUTPUT -m owner --uid-owner 1003 -j DROP

### x03-s4-games
iptables -A OUTPUT -m owner --uid-owner 1033 -j DROP

# IPV6

## Flush existing rules
ip6tables -F
ip6tables -X
ip6tables -Z
ip6tables -t nat -F
ip6tables -t nat -X
ip6tables -t mangle -F
ip6tables -t mangle -X

## Set default policies
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

## Allow lo
ip6tables -A INPUT -i lo -j ACCEPT

## Allow established/related connections
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# ICMP configuration
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP 
ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -j REJECT --reject-with icmp6-port-unreachable
ip6tables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j REJECT --reject-with tcp-reset

## Deny internet connection for users.

### x00-s4-games
ip6tables -A OUTPUT -m owner --uid-owner 1003 -j DROP

### x03-s4-games
ip6tables -A OUTPUT -m owner --uid-owner 1033 -j DROP

# Save configuration and restart service.

/etc/init.d/iptables save
/etc/init.d/ip6tables save

rc-service iptables restart
rc-service ip6tables restart
