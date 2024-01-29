#!/usr/bin/env bash

description="Line-in listening management"
# version: 12.1
# author: Choops <choopsbd@gmail.com>

set -e

DEF="\e[0m"
RED="\e[31m"
GRN="\e[32m"
YLO="\e[33m"
CYN="\e[36m"

ERR="${RED}E${DEF}:"
OK="${GRN}OK${DEF}:"

usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  $(basename "$0") [OPTION] <OPTION>"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help: Print this help"
    echo -e "  on:        Start listening to line-in"
    echo -e "  off:       Stop listening to line-in"
    echo

    exit "${errcode}"
}

[[ $# != 1 ]] && echo -e "${ERR} Need one and only one argument" && usage 1
[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $1 = on ]]; then
    pactl load-module module-loopback latency_msec=1
elif [[ $1 = off ]]; then
    pactl unload-module module-loopback
elif [[ $1 ]]; then
    echo "${ERR} Bad argument"
fi
