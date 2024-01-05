#!/usr/bin/env bash

description="Deploy my personal xfce configuration"
# version: 12.0
# author: Choops <choopsbd@gmail.com>

#set -ex    # debug

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

STABLE=bookworm
TESTING=trixie


usage(){
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

stable_sources(){
    cat <<EOF > /etc/apt/sources.list
# ${STABLE}
deb http://deb.debian.org/debian/ ${STABLE} main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian/ ${STABLE} main contrib non-free non-free-firmware
# ${STABLE} security
deb http://deb.debian.org/debian-security/ ${STABLE}-security/updates main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian-security/ ${STABLE}-security/updates main contrib non-free non-free-firmware
# ${STABLE} volatiles
deb http://deb.debian.org/debian/ ${STABLE}-updates main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian/ ${STABLE}-updates main contrib non-free non-free-firmware
# ${STABLE} backports
deb http://deb.debian.org/debian/ ${STABLE}-backports main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian/ ${STABLE}-backports main contrib non-free non-free-firmware
EOF
}

testing_sources(){
    cat <<EOF > /etc/apt/sources.list
# testing
deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware

# testing security
deb http://deb.debian.org/debian-security/ testing-security/updates main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian-security/ testing-security/updates main contrib non-free non-free-firmware
EOF
}

sid_sources(){
    cat <<EOF > /etc/apt/sources.list
# sid
deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware 
EOF
}

clean_sources(){
    version="$1"
    echo -e "${NFO} Cleaning sources.list..."
    if [[ ${version} == "${STABLE}" ]]; then
        stable_sources
    elif [[ ${version} == "${TESTING}" ]]; then
        testing_sources
    else
        sid_sources
    fi
}

apply_config(){
    [[ ${clsrc} == y ]] && clean_sources
}

get_longest_elt_length(){
    echo "$@" | sed "s/ /\n/g" | wc -L
}

clsrc_menu(){
    clsrc_title="Clean sources.list"
    clsrc_text="Modify /etc/apt/sources.list to include properly all needed branches ?"
    (whiptail --title "${clsrc_title}" --yesno "${clsrc_text}" 8 78) && clsrc=y
}

softs_menu(){
    softs_title="Optional softwares"
}

games_menu(){
    games_title="Games"
}

usrcfg_menu(){
    usrcfg_title="User config"
}

config_menus(){
    # whiptail colors
    export NEWT_COLORS="
    root=,blue
    window=,black
    shadow=,blue
    border=blue,black
    title=white,black
    textbox=white,black
    radiolist=black,black
    label=black,blue
    checkbox=black,white
    compactbutton=black,lightgray
    button=white,blue"

    clsrc_menu
    softs_menu
    games_menu
    usrcfg_menu
}


# check arguments
[[ $2 ]] && echo -e "${ERR} Too many arguments" && usage 1
if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

# check relevance
[[ $(whoami) != root ]] && echo -e "${ERR} Need higher privileges" && exit 1

my_dist="$(awk -F= '/^ID=/{print $2}' /etc/os-release)"
[[ ${my_dist} != debian ]] &&
    echo -e "${ERR} $(basename "$0") works only on Debian" && exit 1

debian_version="$(lsb_release -sc)"
if [[ ${debian_version} == "${TESTING}" ]]; then
    for vers in sid unstable; do
        grep -q "^deb .*${vers}" /etc/apt/sources.list && debian_version=sid
    done
fi

! [[ "$STABLE $TESTING sid" =~ (\ |^)$debian_version(\ |$) ]] &&
        echo -e "${ERR} Unsupported version '${version}'" && exit 1

# go!
config_menus
apply_config

exit 0
