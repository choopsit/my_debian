#!/usr/bin/env bash

set -e

description="Install/Update McMojave cursors"
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

THEMES_DIR=/usr/share/icons

cursors=McMojave-cursors
git_url="https://github.com/vinceliuice/McMojave-cursors.git"


usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  $(basename "$0") [OPTION]"
    echo -e "${CYN}Options${DEF}:"
    echo -e "${NFO} No option => install ${cursors}"
    echo -e "  -h,--help:   Print this help"
    echo -e "  -r,--remove: Remove ${cursors}"
    echo

    exit "${errcode}"
}

bye_cursors() {
    [[ ! -d "${THEMES_DIR}" ]] && echo -e "${NFO} ${cursors} is not installed\n" && exit 0

    echo -e "${NFO} Removing ${cursors}..."

    sudo rm -rf "${THEMES_DIR}"/McMojave*
    rm -rf "${thm_gitpath}"
    echo
    exit 0
}

hello_cursors() {
    echo -e "${NFO} Installing/Updating ${cursors}..."

    if [[ -d "${thm_gitpath}" ]]; then
        pushd "${thm_gitpath}" >/dev/null
        upd_state="$(git pull | tee /dev/tty)"
        popd >/dev/null
    elif [[ $(whoami) != root ]]; then
        echo -e "${WRN} '${cursors}' repo must be cloned in '${HOME}/Work/git' before it can be updated"
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
        pushd "${thm_gitpath}" >/dev/null
        if [[ $(whoami) == root ]]; then
            ./install.sh
        else
            sudo ./install.sh
        fi
        popd >/dev/null
    fi
    echo
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $(whoami) == root ]]; then
    thm_gitpath=/tmp/"${cursors}"
else
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

    thm_gitpath="${HOME}"/Work/git/"${cursors}"

    [[ $1 =~ ^-(r|-remove)$ ]] && bye_cursors

    [[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

    sudo true
fi

hello_cursors
