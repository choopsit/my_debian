#!/usr/bin/env bash

set -e

description="Install/Update Gruvbox gtk-theme gruvbox and nord variants"
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

THEMES_DIR=/usr/share/themes

gtk_theme=Gruvbox-GTK-Theme
#git_url="https://github.com/SylEleuth/Gruvbox-GTK-Theme"
git_url="https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme"
theme_name=Gruvbox-Dark-BL


usage() {
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

bye_gtk() {
    [[ ! -d "${THEMES_DIR}" ]] && echo -e "${NFO} ${gtk_theme} is not installed\n" && exit 0

    echo -e "${NFO} Removing ${gtk_theme}..."

    sudo rm -rf "${THEMES_DIR}"/Gruvbox*
    rm -rf "${thm_gitpath}"
    echo
    exit 0
}

hello_gtk() {
    echo -e "${NFO} Installing/Updating ${gtk_theme}..."

    pkg=gtk2-engines-murrine
    if ! (dpkg -l | grep -q "^ii  ${pkg}"); then
        if [[ $(whoami) == root ]]; then
            xargs apt install -y "${pkg}"
        else
            sudo xargs apt install -y "${pkg}"
        fi
    fi

    if [[ -d "${thm_gitpath}" ]]; then
        pushd "${thm_gitpath}" >/dev/null
        upd_state="$(git pull | tee /dev/tty)"
        popd >/dev/null
    elif [[ $(whoami) != root ]]; then
        echo -e "${WRN} '${gtk_theme}' repo must be cloned in '${HOME}/Work/git' before it can be updated"
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

    if ! [[ ${upd_state} =~ ^(Already up to date.|Déjà à jour.)$ ]] ; then
        if [[ $(whoami) == root ]]; then
            rm -rf "${THEMES_DIR}"/"${theme_name}"
            cp -r "${thm_gitpath}"/themes/"${theme_name}" "${THEMES_DIR}"/
        else
            sudo rm -rf "${THEMES_DIR}"/"${theme_name}"
            sudo cp -r "${thm_gitpath}"/themes/"${theme_name}" "${THEMES_DIR}"/
        fi
    fi
    echo
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $(whoami) == root ]]; then
    thm_gitpath=/tmp/"${gtk_theme}"
else
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

    thm_gitpath="${HOME}"/Work/git/"${gtk_theme}"

    [[ $1 =~ ^-(r|-remove)$ ]] && bye_gtk

    [[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

    sudo true
fi

hello_gtk
