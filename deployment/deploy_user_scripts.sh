#!/usr/bin/env bash

set -e

description="Deploy bash scripts to ~/.local/bin"
# version: 12.0
# author: Choops <choopsbd@gmai

DEF="\e[0m"
RED="\e[31m"
GRN="\e[32m"
YLO="\e[33m"
CYN="\e[36m"

ERR="${RED}ERR${DEF}:"
OK="${GRN}OK${DEF}:"
WRN="${YLO}WRN${DEF}:"
NFO="${CYN}NFO${DEF}:"

STABLE=bullseye
TESTING=bookworm


usage(){
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  '$(realpath "$0") [OPTION]'"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help: Print this help"
    echo

    exit "${errcode}"
}


if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

script_dir="$(dirname "$(realpath "$0")")"
bash_scripts_dir="$(realpath "${script_dir}"/../scripts)"

echo -e "${NFO} Deploying bash scripts to '${YLO}${HOME}/.local/bin/${DEF}'..."

mkdir -p "${HOME}"/.local/bin

for subfolder in "${bash_scripts_dir}"/*; do
    for bash_script in "${subfolder}"/*; do
        script_name="$(basename "${bash_script}")"
        if (ln -sf "${bash_script}" "${HOME}"/.local/bin/"${script_name%.*}"); then
            echo -e "${OK} '${YLO}${bash_script}${DEF}' linked to '~/.local/bin/${CYN}${script_name%.*}${DEF}'"
        else
            echo -e "${ERR} Failed to link '${script_name}'"
        fi
    done
done
