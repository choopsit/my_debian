#!/usr/bin/env bash

#set -e

description="Install/Update my personal choice of gtk/cursors/icons-themes"
# version: 12.1
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


usage() {
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

git_base="${HOME}/Work/git"
thm_list=("colloid_gtk" "whitesur_cursors")
#[[ -d "${git_base}/Colloid-gtk" ]] && thm_list+=("colloid_gtk")
[[ -d "${git_base}/Gruvbox-GTK-Theme" ]] && thm_list+=("gruvbox_gtk")
[[ -d "${git_base}/gruvbox-plus-icon-pack" ]] && thm_list+=("gruvbox_icons")
[[ -d "${git_base}/kora" ]] && thm_list+=("kora_icons")
[[ -d "${git_base}/McMojave-cursors" ]] && thm_list+=("mcmojave_cursors")
[[ -d "${git_base}/Mojave-gtk-theme" ]] && thm_list+=("mojave_gtk")
#[[ -d "${git_base}/WhiteSur-cursors" ]] && thm_list+=("whitesur_cursors")
[[ -d "${git_base}/WhiteSur-gtk-theme" ]] && thm_list+=("whitesur_gtk")
[[ -d "${git_base}/WhiteSur-icon-theme" ]] && thm_list+=("whitesur_icons")

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
