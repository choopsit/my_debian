#!/usr/bin/env bash

set -e

description="Install/Update WhiteSur gtk/cursors/icons-theme"
# version: 12.0
# author: Choops <choopsbd@gmail.com>

DEF="\e[0m"
RED="\e[31m"
GRN="\e[32m"
YLO="\e[33m"
CYN="\e[36m"
GRY="\e[37m"

ERR="${RED}ERR${DEF}:"
OK="${GRN}OK${DEF}:"
WRN="${YLO}WRN${DEF}:"
NFO="${CYN}NFO${DEF}:"


usage(){
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  $(basename "$0") [OPTION]"
    echo -e "${CYN}Options${DEF}:"
    echo -e "${NFO} No option => install ${gtk_theme}"
    echo -e "  -h,--help:   Print this help"
    echo -e "  -r,--remove: Remove ${gtk_theme}"
    echo

    exit "${errcode}"
}

whitesur(){
    [[ -e ~/.local/bin/whitesur_gtk ]] && whitesur_gtk "$1"
    errcode="$?"
    [[ -e ~/.local/bin/whitesur_cursors ]] && whitesur_cursors "$1"
    errcode="$((errcode+$?))"
    [[ -e ~/.local/bin/whitesur_icons ]] && whitesur_icons "$1"
    errcode="$((errcode+$?))"
    exit "${errcode}"
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

(groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

[[ $1 =~ ^-(r|-remove)$ ]] && whitesur -r

[[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

whitesur
