#!/usr/bin/env bash

set -e

description="Install/Update Colloid gtk-theme gruvbox and nord variants"
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

THEMES_DIR=/usr/share/themes

gtk_theme=Colloid-gtk-theme
git_url="https://github.com/vinceliuice/Colloid-gtk-theme.git"


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

bye_gtk(){
    echo -e "${NFO} Removing ${gtk_theme}..."

    sudo rm -rf "${THEMES_DIR}"/Colloid*
}

byebye_gtk(){
    [[ ! -d "${THEMES_DIR}" ]] && echo -e "${NFO} ${gtk_theme} is not installed\n" && exit 0

    bye_gtk
    echo
    exit 0
}

hello_gtk(){
    thm_gitpath="$1"

    echo -e "${NFO} Installing/Updating ${gtk_theme}..."

    if [[ $(whoami) != root ]]; then
        higher="sudo"
    fi

    pkg_list=/tmp/pkglist

    rm -f "${pkg_list}"

    for pkg in sassc gtk2-engines-murrine; do
        (dpkg -l | grep -q "^ii  ${pkg}") || echo "${pkg}" >>"${pkg_list}"
    done

    [[ -f "${pkg_list}" ]] && "${higher}" xargs apt install -y < "${pkg_list}"

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

    if [[ ${upd_state} != "Already up to date." ]]; then
        sed -e 's/xfce4-panel -r/echo -n/' \
            -e 's/^\([[:space:]]*\)echo.*gnome-shell.*/\1echo -n/' \
            -i "${thm_gitpath}"/install.sh

        "${higher}" rm -rf "${THEMES_DIR}"/"${theme_name}"

        for variant in gruvbox nord; do
            "${higher}" "${thm_gitpath}"/install.sh -c dark --tweaks "${variant}"
        done
        
        pushd "${thm_gitpath}" >/dev/null
        git reset --hard HEAD -q
        popd >/dev/null
    fi
    echo
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

if [[ $(whoami) == root ]]; then
    gitpath=/tmp/"${gtk_theme}"
else
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1

    [[ $1 =~ ^-(r|-remove)$ ]] && byebye_gtk

    [[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1

    sudo true
    gitpath="${HOME}"/Work/git/"${gtk_theme}"
fi

hello_gtk "${gitpath}"
