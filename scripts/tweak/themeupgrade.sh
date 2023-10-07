#!/usr/bin/env bash

#set -e

description="Install/Update my personal choice of gtk/cursors/icons-themes"
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

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

thm_list=("colloid_gtk" "gruvbox_icons")
#thm_list=("gruvbox_gtk" "whitesur_gtk" "mojave_gtk" "kora_icons" "whitesur_cursors" "mcmojave_cursors")


usage(){
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  $(basename "$0") [OPTION]"
    echo -e "${CYN}Options${DEF}:"
    echo -e "${NFO} No option => install ${gtk_theme}"
    echo -e "  -h,--help:   Print this help"
    echo

    exit "${errcode}"
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $(whoami) == root ]]; then
    # install only
    for thm in ${thm_list[@]}; do
        if [[ -e "${SCRIPT_PATH}/${thm}".sh ]]; then
            thname="${thm^}"
            echo -e "${CYN}${thname/_/\ }-theme upgrade${DEF}:"
            "${SCRIPT_PATH}/${thm}".sh
        fi
    done
else
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

    [[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

    for thm in ${thm_list[@]}; do
        if [[ -e ~/.local/bin/"${thm}" ]]; then
            thname="${thm^}"
            echo -e "${CYN}${thname/_/\ }-theme upgrade${DEF}:"
            "${thm}"
        fi
    done
fi
