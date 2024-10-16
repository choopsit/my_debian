#!/usr/bin/env bash

description="Deploy my personal desktop configuration"
# version: 12.1
# author: Choops <choopsbd@gmail.com>

set -e

DEF="\e[0m"
RED="\e[31m"
GRN="\e[32m"
YLO="\e[33m"
CYN="\e[36m"

ERR="${RED}ERR${DEF}:"
OK="${GRN}OK${DEF}:"
WRN="${YLO}WRN${DEF}:"
NFO="${CYN}NFO${DEF}:"

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

# whiptail colors
export NEWT_COLORS="
root=,blue
window=,black
shadow=,blue
border=blue,black
title=white,black
textbox=white,black
radiolist=black,blue
label=black,blue
checkbox=black,white
compactbutton=black,lightgray
button=white,red"


usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}" &&
        echo -e "${WRN} It's a combination of personal choices. Use it at your own risk."

    echo -e "${CYN}Usage${DEF}:"
    echo -e "  ./$(basename "$0") [OPTION]"
    echo -e "  ${WRN} Must be run as 'root' or using 'sudo'"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help: Print this help"
    echo

    exit "${errcode}"
}


[[ $2 ]] && echo -e "${ERR} Too many arguments" && usage 1
if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

[[ $(whoami) != root ]] && echo -e "${ERR} Need higher privileges" && exit 1

my_dist="$(awk -F= '/^ID=/{print $2}' /etc/os-release)"
[[ ${my_dist} != debian ]] &&
    echo -e "${ERR} $(basename "$0") works only on Debian" && exit 1

de_list=("xfce" "gnome")

if [[ ${#de_list[@]} -gt 1 ]]; then
    # TODO: replace this by whiptail TUI
    i=0
    echo -e "${CYN}Available Desktop Environment configurations${DEF}:"
    for de_name in "${de_list[@]}"; do
        i=$((i+1))
        echo "  ${i} - ${de_name}"
    done

    read -p "Choose your poison: " -rn1 de_idx
    [[ ${de_idx} ]] && echo

    if [[ ! ${de_idx} =~ '^[1-9]$' ]]; then
        nb_de="${#de_list[@]}"
        if [[ ${de_idx} -ge 1 ]] && [[ ${de_idx} -le ${nb_de} ]]; then
            de="${de_list[$((de_idx-1))]}"
        else
            echo -e "${ERR} Invalid choice" && exit 1
        fi
    else
        echo -e "${ERR} Invalid choice" && exit 1
    fi
else
    de="${de_list[0]}"
fi

"${SCRIPT_PATH}/config/my_${de}.sh"
