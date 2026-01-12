#!/usr/bin/env bash

set -e

description="reformat and colorize df output"
# version: 12.1
# author: Choops <choopsbd@gmail.com>

DEF="\e[0m"
BLK="\e[30m"
RED="\e[31m"
GRN="\e[32m"
YLO="\e[33m"
BLU="\e[34m"
PUR="\e[35m"
CYN="\e[36m"
GRY="\e[37m"

ERR="${RED}ERR${DEF}:"
OK="${GRN}OK${DEF}:"
WRN="${YLO}WRN${DEF}:"
NFO="${CYN}NFO${DEF}:"


usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"

    echo -e "${CYN}Usage${DEF}:"
    echo -e "  '$(basename "$0") [OPTION]' as root or using sudo"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help: Print this help"
    echo

    exit "${errcode}"
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0

[[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1


echo -e "${CYN}Filesystems${DEF}:"
while read line; do
    df_elts=(${line})

    devmap=${df_elts[0]}
    sepdev=""

    fstype=${df_elts[1]}

    for i in $(seq 1 "$((51-${#devmap}-${#fstype}))"); do
        sepdev+=" "
    done

    if [[ ${fstype} =~ ^(nfs|cifs) ]]; then
        fscol="${BLU}"
    elif [[ ${fstype} =~ ^fuse ]]; then
        fscol="${PUR}"
    else
        fscol="${GRY}"
    fi
    sepfs=" -----${DEF}> "

    fsline="${fscol}${devmap}${DEF}${sepdev}"
    fsline+=" ${fscol}${fstype}${sepfs}"

    mntpoint=${df_elts[6]}
    sepmp=" "
    for i in $(seq 1 "$((26-${#mntpoint}))"); do
        sepmp+=" "
    done
    fsline+="${mntpoint}${sepmp}\n["

    pctused=${df_elts[5]}
    pctu=${pctused%\%}
    if [[ ${pctu} -le 90 ]]; then
        grcol="${GRN}"
    elif [[ ${pctu} -gt 95 ]]; then
        grcol="${RED}"
    else
        grcol="${YLO}"
    fi
    used=$((pctu/2))
    gru=""
    for i in $(seq 1 "${used}"); do
        gru+="#"
    done
    grf=""
    for i in $(seq "$((used+1))" 50); do
        grf+="-"
    done
    graph="${grcol}${gru}${fscol}${grf}"
    seppct=" "
    [[ ${#pctu} -lt 2 ]] && seppct="  "
    fsline+="${graph}${DEF}] ${seppct}${grcol}${pctu}${DEF}% -"

    used=${df_elts[3]}
    size=${df_elts[2]}
    sepsp=""
    for i in $(seq 1 "$((5-${#used}))"); do
        sepsp+=" "
    done
    sepsp2=" "
    for i in $(seq 1 "$((5-${#size}))"); do
        sepsp2+=" "
    done
    fsline+="${sepsp}${grcol}${used}${DEF}/${grcol}${size}${DEF}${sepsp2}-"

    free=${df_elts[4]}
    sepf=" "
    for i in $(seq 1 "$((5-${#free}))"); do
        sepf+=" "
    done
    fsline+="${sepf}${grcol}${free}${DEF} free"

    echo -e "${fsline}"
done < <(df -hT | grep -v 'tmpfs\|^Filesystem\|^Sys\|efivarfs')

echo
