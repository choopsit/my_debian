#!/usr/bin/env bash

#set -e

description="Install or remove widevine lib in chromium"
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


usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  $(basename "$0") [OPTION]"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help:   Print this help"
    echo -e "  -r,--remove: Remove widevine lib"
    echo -e "  ${YLO}no option  ${DEF}: Install widevine"
    echo

    exit "${errcode}"
}


if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 = -r ]]; then
    sudo rm -f /usr/lib/chromium/libwidevinecdm.so && echo -e "${OK} widevine lib removed"
elif [[ $1 ]]; then
    echo -e "${ERR} unkown argument" && usage 1
else
    pushd /tmp
    wget https://dl.google.com/widevine-cdm/1.4.8.1008-linux-x64.zip
    unzip 1.4.8.1008-linux-x64.zip
    [[ -d /usr/lib/chromium ]] || sudo mkdir /usr/lib/chromium
    sudo mv libwidevinecdm.so /usr/lib/chromium
    sudo chmod 644 /usr/lib/chromium/libwidevinecdm.so
    for file in 1.4.8.1008-linux-x64.zip libwidevinecdm.so manifest.json LICENSE.txt; do
        rm -f /tmp/"${file}"
    done
    popd
    echo -e "${OK} widevine lib installed"
fi
