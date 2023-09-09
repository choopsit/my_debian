#!/usr/bin/env bash

set -e

description="Deploy 'systools' bash and python scripts to /usr/local/bin"
# vrsion: 12.0
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
    echo -e "  '$(realpath "$0") [OPTION]' ${YLO}as root or using 'sudo'${DEF}"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help: Print this help"
    echo

    exit "${errcode}"
}

link_script(){
    script="$1"
    script_name="$(basename "${script}")"
    if (ln -sf "${script}" /usr/local/bin/"${script_name%.*}"); then
        echo -e "${OK} '${YLO}${script}${DEF}' linked to '/usr/local/bin/${CYN}${script_name%.*}${DEF}'"
    else
        echo -e "${ERR} Failed to link '${script_name}'"
    fi
}


if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

[[ $(whoami) != root ]] && echo -e "${ERR} Need higher privileges" && usage 1

script_dir="$(dirname "$(realpath "$0")")"
base_dir="$(realpath "${script_dir}"/../)"

echo -e "${NFO} Deploying bash and python systools to '${YLO}/usr/local/bin/${DEF}'..."

for systool in "${base_dir}"/{bash,python}/systools/*; do
    if [[ -f "${systool}" ]]; then
        link_script "${systool}"
    fi
done
