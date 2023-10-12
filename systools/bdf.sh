#!/usr/bin/env bash

set -e

description="reformat and colorize df output"
# version: 12.0
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


usage(){
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


bdf_file=/tmp/"$(date +%m+%d+%H+%M+%S)"_bdf
df -hT | grep -v 'tmpfs\|^Filesystem' >"${bdf_file}"

echo -e "${CYN}Filesystems${DEF}:"
while read line; do
    devmap="$(awk '{print $1}' <<<"${line}")"
    fsline="${CYN}${devmap#/dev/}${DEF}"

    fstype="$(awk '{print $2}' <<<"${line}")"
    if [[ ${fstype} =~ ^(nfs|cifs) ]]; then
        fscol="${BLU}"
    elif [[ ${fstype} =~ ^fuse ]]; then
        fscol="${PUR}"
    else
        fscol="${GRY}"
    fi
    sepfs=" "
    for i in $(seq 1 "$((5-${#fstype}))"); do
        sepfs+=" "
    done
    fsline+=" [${fscol}${fstype}${DEF}]${sepfs}"

    mntpoint="$(awk '{print $7}' <<<"${line}")"
    sepmp=" "
    for i in $(seq 1 "$((17-${#mntpoint}))"); do
        sepmp+=" "
    done
    fsline+="on ${fscol}${mntpoint}${DEF}${sepmp}["

    pctused="$(awk '{print $6}' <<<"${line}")"
    pctu=${pctused%\%}
    if [[ ${pctu} -le 90 ]]; then
        grcol="${GRN}"
    elif [[ ${pctu} -gt 95 ]]; then
        grcol="${RED}"
    else
        grcol="${YLO}"
    fi
    used=$((pctu/10))
    gru=""
    for i in $(seq 1 "${used}"); do
        gru+="#"
    done
    grf=""
    for i in $(seq "$((used+1))" 10); do
        grf+="-"
    done
    graph="${grcol}${gru}${fscol}${grf}"
    [[ ${#pctu} -gt 1 ]] && seppct=" "
    fsline+="${graph}${DEF}]${seppct}${grcol}${pctu}${DEF}%"

    used="$(awk '{print $4}' <<<"${line}")"
    size="$(awk '{print $3}' <<<"${line}")"
    sepsp=" "
    for i in $(seq 1 "$((5-${#used}))"); do
        sepsp+=" "
    done
    sepsp2=" "
    for i in $(seq 1 "$((4-${#size}))"); do
        sepsp2+=" "
    done
    fsline+="${sepsp}${fscol}${used}${DEF}/${fscol}${size}${sepsp2}${DEF}-"

    free="$(awk '{print $5}' <<<"${line}")"
    sepf=" "
    for i in $(seq 1 "$((4-${#free}))"); do
        sepf+=" "
    done
    fsline+="${sepf}${fscol}${free}${DEF} free"

    echo -e "${fsline}"
done <"${bdf_file}"

echo
