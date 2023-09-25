#!/usr/bin/env bash

set -e

description="Install/Update WhiteSur icon-theme"
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

THEMES_DIR=/usr/share/icons

icon_theme=WhiteSur-icon-theme
git_url="https://github.com/vinceliuice/WhiteSur-icon-theme.git"


usage(){
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  $(basename "$0") [OPTION]"
    echo -e "${CYN}Options${DEF}:"
    echo -e "${NFO} No option => install ${icon_theme}"
    echo -e "  -h,--help:   Print this help"
    echo -e "  -r,--remove: Remove ${icon_theme}"
    echo

    exit "${errcode}"
}

bye_icon(){
    echo -e "${NFO} Removing ${icon_theme}..."
    sudo rm -rf "${THEMES_DIR}"/WhiteSur*
}

byebye_icon(){
    [[ ! -d "${THEMES_DIR}" ]] && echo -e "${NFO} ${icon_theme} is not installed\n" && exit 0
    bye_icon
    echo
    exit 0
}

hello_icon(){
    thm_gitpath="$1"

    echo -e "${NFO} Installing/Updating ${icon_theme}..."

    if [[ $(whoami) != root ]]; then
        higher="sudo"
    fi

    if [[ -d "${thm_gitpath}" ]]; then
        pushd "${thm_gitpath}" >/dev/null
        upd_state="$(git pull | tee /dev/tty)"
        popd >/dev/null
    elif [[ $(whoami) != root ]]; then
        echo -e "${WRN} '${icon_theme}' repo must be cloned in '${HOME}/Work/git' before it can be updated"
        read -p "Do it now [y/N] ? " -rn1 go4it
        [[ ${go4it} ]] && echo

        if [[ ${go4it,} = y ]]; then
            mkdir -p "${HOME}"/Work/git
            git clone "${git_url}" "${thm_gitpath}"
        else
            exit 0
        fi
    else
        rm -rf "${thm_gitpath}"
        git clone "${git_url}" "${thm_gitpath}"
    fi

    if [[ ${upd_state} != "Already up to date." ]]; then
        "${higher}" "${thm_gitpath}"/install.sh --black -b
    fi
    echo
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $(whoami) == root ]]; then
    gitpath=/tmp/"${icon_theme}"
else
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

    [[ $1 =~ ^-(r|-remove)$ ]] && byebye_icon

    [[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

    sudo true
    gitpath="${HOME}"/Work/git/"${icon_theme}"
fi

hello_icon "${gitpath}"
