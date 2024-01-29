#!/usr/bin/env bash

set -e

description="Install/Update tilix gruvbox theme"
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

THEMES_DIR=/usr/share/tilix/schemes
tilix_theme=tilix-gruvbox
git_url=https://github.com/MichaelThessel/tilix-gruvbox.git
thm_gitpath="${HOME}"/Work/git/"${tilix_theme}"


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

install_tilix_gruvbox() {
    if [[ -d "${THEMES_DIR}" ]]; then
        if [[ -d ~/Work/git/"${tilix_theme}" ]]; then
            echo -e "${NFO} Installing/Updating ${tilix_theme}..."

            pushd "${thm_gitpath}" >/dev/null
            git pull
            popd >/dev/null
            echo
        else
            echo -e "${WRN} '${tilix_theme}' repo must be cloned in '${HOME}/Work/git' before it can be updated"
            read -p "Do it now [y/N] ? " -rn1 go4it
            [[ ${go4it} ]] && echo

            if [[ ${go4it,} = y ]]; then
                mkdir -p "${HOME}"/Work/git
                pushd "${HOME}"/Work/git >/dev/null
                git clone ${git_url}
                popd >/dev/null
            else
                exit 0
            fi
        fi

        sudo cp -rf "${thm_gitpath}"/gruvbox-* "${THEMES_DIR}"/
    else
        echo -e "${ERR} 'tilix' not installed."
        exit 1
    fi
}

remove_tilix_gruvbox() {
    sudo rm -rf "${THEMES_DIR}"/gruvbox-* 
    rm -rf "${thm_gitpath}"
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

(groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

[[ $1 =~ ^-(r|-remove)$ ]] && remove_tilix_gruvbox

[[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

install_tilix_gruvbox
