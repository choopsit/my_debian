#!/usr/bin/env bash

set -e

description="Create USB bootable key with debian stable on it"
# version: 12.1
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

DEBIAN_V=12.2.0
MINT_V=21.2
GPARTED_V=1.4.-5


usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"

    echo -e "${CYN}Usage${DEF}:"
    echo -e "  '$(basename "$0") [OPTION] <DEVICE>' as root or using sudo"
    echo -e "  ${YLO}with DEVICE the device in /dev/ corrsponding to your USB key"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help: Print this help"
    echo

    exit "${errcode}"
}

check_usbkey() {
    device="$1"
    if mount | grep -q "${device}"; then
        echo -e "${NFO} Mounted partition(s) from device '${device}'"
    else
        echo -e "${ERR} No partition from device '${device}' mounted" && exit 1
    fi
}

choose_support() {
    support=""
    choices=("debian stable" "linuxmint" "gparted")
    iso_urls[0]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-${DEBIAN_V}-amd64-netinst.iso"
    iso_urls[1]="https://mirror.johnnybegood.fr/mint-cd/stable/${MINT_V}/linuxmint-${MINT_V}-cinnamon-64bit.iso"
    iso_urls[2]="https://sourceforge.net/projects/gparted/files/gparted-live-stable/${GPARTED_V}/gparted-live-${GPARTED_V}-amd64.iso/download"

    echo -e "${CYN}Choose your distro${DEF}:"
    for i in $(seq 0 "$((${#choices[@]}-1))"); do
        echo "  ${i} - ${choices[${i}]}"
    done
    echo -e "  ${YLO}${#choices[@]}${DEF} - ${YLO}Abort${DEF}"
    read -rp "Your choice ? " -n1 s_choice
    [[ ${s_choice} ]] && echo
    if [[ ${s_choice} =~ ^[0-9]+$ ]] && [[ ${s_choice} -le ${#choices[@]} ]]; then
        [[ ${s_choice} == ${#choices[@]} ]] && exit 0
        support=${choices[${s_choice}]}
        iso_url=${iso_urls[${s_choice}]}
    else
        echo -e "${ERR} Invalid choice '${s_choice}'"
        choose_support
    fi
}

get_iso() {
    iso_url="$1"
    echo -e "${NFO} Downloading ${YLO}${iso_url##*/}${DEF}..."
    wget -O /tmp/my.iso "${iso_url}"
}

burn_support() {
    support="$1"
    device="$2"
    echo -e "${NFO} Deploying ${YLO}${support}${DEF} on '${YLO}${device}${DEF}'..."
    dd bs=4M if=/tmp/my.iso of="${device}" conv=fdatasync
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

[[ $(whoami) != root ]] && echo -e "${ERR} Need higher privileges" && usage 1

if [[ ! $1 ]]; then
    echo -e "${ERR} Need an argument" && usage 1
elif [[ -e "/dev/$1" ]]; then
    device="/dev/$1"
else
    echo -e "${ERR} No device '/dev/$1' found" && usage 1
fi

check_usbkey "${device}"

echo -e "${WRN} You are about to format '${device}'"
read -p "Continue [y/N] ? " -n1 letsgo
[[ ${letsgo} ]] && echo
[[ ${letsgo,,} == y ]] || exit 0

choose_support

get_iso "${iso_url}"

burn_support "${support}" "${device}"
