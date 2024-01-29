#!/usr/bin/env bash

description="Set puseaudio-plugin volume control step"
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
    echo -e "  $(basename "$0") [OPTION] <STEP>"
    echo -e "  ${YLO}with STEP the percentage to apply to volume control step between 1 and 20${DEF}"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help: Print this help"
    echo

    exit "${errcode}"
}

[[ $# != 1 ]] && echo -e "${ERR} Need one and only one argument" && usage 1
[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $1 -lt 1 ]] || [[ $1 -gt 20 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

! (ps -C xfce4-panel >/dev/null) && echo -e "${ERR} DE is not XFCE" && exit 1

pa_step="$1"
pulseplug="$(xfconf-query -c xfce4-panel -lv | awk '/pulseaudio/ {print $1}')"

xfconf-query -c xfce4-panel -p "${pulseplug}"/volume-step --create -t int -s "${pa_step}"

echo -e "${OK} Volume control step set to ${pa_step}%\n"
