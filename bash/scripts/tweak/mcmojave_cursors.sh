#!/usr/bin/env bash

set -e

description="Install/Update McMojave cursors"
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

cursors=McMojave-cursors
git_url="https://github.com/vinceliuice/McMojave-cursors.git"


usage(){
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

bye_cursors(){
    echo -e "${NFO} Removing ${cursors}..."
    sudo rm -rf "${THEMES_DIR}"/McMojave*
}

byebye_cursors(){
    [[ ! -d "${THEMES_DIR}" ]] && echo -e "${NFO} ${cursors} is not installed\n" && exit 0
    bye_cursors
    echo
    exit 0
}

hello_cursors(){
    if [[ -d ~/Work/git/"${cursors}" ]]; then
        echo -e "${NFO} Installing/Updating ${cursors}..."

        pushd "${HOME}"/Work/git/"${cursors}" >/dev/null
        git pull
        popd >/dev/null
    else
        echo -e "${WRN} '${cursors}' repo must be cloned in '${HOME}/Work/git' before it can be updated"
        read -p "Do it now [y/N] ? " -rn1 go4it
        [[ ${go4it} ]] && echo

        if [[ ${go4it,} = y ]]; then
            mkdir -p "${HOME}"/Work/git
            git clone "${git_url}" "${HOME}"/Work/git/"${cursors}"
        else
            exit 0
        fi
    fi

    pushd "${HOME}"/Work/git/"${cursors}" >/dev/null
    sudo ./install.sh >/dev/null
    popd >/dev/null
    echo
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $(whoami) == root ]]; then
    # install only
    rm -rf /tmp/"${cursors}"
    rm -rf "${THEMES_DIR}"/"${cursors}"

    git clone "${git_url}" /tmp/"${cursors}"

    pushd /tmp/"${cursors}" >/dev/null
    ./install.sh
    popd >/dev/null
    echo
else
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

    [[ $1 =~ ^-(r|-remove)$ ]] && byebye_cursors

    [[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

    sudo true

    hello_cursors
fi
