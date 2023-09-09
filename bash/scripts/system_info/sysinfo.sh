#!/usr/bin/env bash

#set -e

description="Display system informations"
# version: 12.0
# author: Choops <choopsbd@gmail.com>

DEF="\e[0m"
RED="\e[31m"
GRN="\e[32m"
YLO="\e[33m"
CYN="\e[36m"

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
    echo -e "  -h,--help:    Print this help"
    echo -e "  -u,--upgrade: Upgrade system before displaying informations"
    echo -e "  -ub: Upgrade system and do a backup before displaying informations"
    echo

    exit "${errcode}"
}

sys_upgrade(){
    echo -e "${CYN}System Upgrade${DEF}:"
    echo -e "${NFO} Upating repos..."
    sudo apt update

    echo -e "\n${NFO} Upgrading..."
    sudo apt full-upgrade

    echo -e "\n${NFO} Purging unneeded packages..."
    sudo apt autoremove --purge
    echo
}

sys_info(){
    echo -e "${CYN}System Informations${DEF}:"
    date +"%a %d %b %Y - %R:%S"
    echo

    pyfetch

    (dpkg -l | grep -q "^ii  virtualbox ") &&
        [[ $(VBoxManage list runningvms) ]] &&
        echo -e "${CYN}Virtual Machine(s) running${DEF}:" &&
        VBoxManage list runningvms | awk -F'"' '{print $2}' &&
        echo

    (dpkg -l | grep -q "^ii  libvirt0") && (virsh list | grep -q running) &&
        echo -e "${CYN}Virtual Machine(s) running${DEF}:" &&
        virsh list | awk '/running/{print $2}' &&
        echo

    (dpkg -l | grep -q "^ii  transmission-daemon") &&
        [[ -e ~/.local/bin/tsm ]] && tsm -t

    pydf
}


if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 =~ ^-(u|-upgrade)$ ]]; then
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1
    do_upgrade=true
elif [[ $1 == -ub ]]; then
    (groups | grep -qv sudo) && echo -e "${ERR} Need 'sudo' rights" && exit 1
    do_upgrade=true
    do_backup=true
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

if [[ ${do_upgrade} ]] ; then
    [[ -e "${HOME}"/.local/bin/themeupgrade ]] && "${HOME}"/.local/bin/themeupgrade
    sys_upgrade
fi

bkp_dest=/volumes/backup
if [[ ${do_backup} ]] && [[ -e ~/.local/bin/backup ]] &&
    (dpkg -l | grep -q ^"ii  rsync"); then
    echo -e "${CYN}Backup${DEF}:"
    if (mount | grep -q " ${bkp_dest} "); then
        backup
    else
        echo -e "${WRN} ${bkp_dest} not mounted\n"
    fi
fi

sys_info

gits="${HOME}/Work/git"
[[ -e ~/.local/bin/statgitrepos ]] && [[ -d "${gits}" ]] &&
    echo -e "${CYN}Git repo(s) status${DEF}:" && statgitrepos
