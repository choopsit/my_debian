#!/usr/bin/env bash

set -e

description="Make 'transmission-cli' manipulations simplified"
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
    echo -e "  $(basename "$0") <OPTION>"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  ${YLO}No option${DEF}:    Show queue"
    echo -e "  -h,--help:    Print this help"
    echo -e "  -a,--add:     Add .torrent files from ~/Download to queue"
    echo -e "  -d <ID>:      Remove torrent with id ID and delete downloaded data"
    echo -e "  -t,--test:    Test port"
    echo -e "  -r,--restart: Restart transmission-daemon ${YLO}(need 'sudo' rights)${DEF}"
    echo

    exit "${errcode}"
}

show_queue() {
    clear
    show_cmd="transmission-remote -l && echo '\nPress <Ctrl>+<C> to quit'"
    watch "${show_cmd}"
}

restart_daemon() {
    echo -e "${NFO} Restarting transmission-daemon..."
    sudo systemctl restart transmission-daemon
    echo -e "${OK} Transmission-daemon restarted\n"
}

tsmd_status() {
    my_port="$1"
    echo -e "${CYN}Transmission-daemon status${DEF}:"
    echo -e "${NFO} Testing port '${YLO}${my_port}${DEF}'..."

    test_result="$(transmission-remote -pt)"

    if [[ ${test_result} == *Yes ]]; then
        echo -e "${OK} ${test_result}\n"
    else
        echo -e "${ERR} ${test_result}\n" && exit 1
    fi
}

test_port() {
    tsm_conf="${HOME}/.config/transmission-daemon/settings.json"

    [[ ! -f ${tsm_conf} ]] &&
        echo -e "${ERR} Cannot find transmission-daemon configuration file\n" &&
        exit 1

    port="$(awk '/\"peer-port\"/ {print substr($2, 1, length($2)-1)}' "${tsm_conf}")"

    if [[ ${port} ]]; then
        tsmd_status "${port}"
    else
        echo -e "${ERR} Can not find port in transmission-daemon config\n" && exit 1
    fi
}

add_me() {
    my_t="$1"

    if [[ -f "${my_t}" ]]; then
        tname="$(basename "${my_t}")"

        echo -e "${NFO} Adding '${YLO}${tname}${DEF}'..."
        transmission-remote -a "${my_t}" && rm "${my_t}"
        echo -e "${OK} '${tname%.*}' added to queue"
        echo
    fi
}

add_torrents() {
    for torrent in "${HOME}"/Downloads/*.torrent; do
        add_me "${torrent}"
    done
}

remove_torrent() {
    torrent_id="$2"
    if [[ $(transmission-remote -t "${torrent_id}" -i) ]]; then
        tname="$(transmission-remote -t "${torrent_id}" -i | awk '/Name:/ {print $2}')"

        echo -e "${NFO} Removing '${YLO}${tname}${DEF}'..."
        transmission-remote -t "${torrent_id}" -rad
        echo -e "${OK} '${tname}' removed from queuei\n"
    else
        echo -e "${ERR} No torrent with id ${torrent_id} in queue\n"
        exit 1
    fi
}

if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 =~ ^-(a|-add)$ ]]; then
    add_torrents
elif [[ $1 == -d ]]; then
    if [[ $3 ]]; then
        echo -e "${ERR} Too many arguments" && usage 1
    elif [[ $2 ]]; then
        remove_torrent "$2"
    else
        echo -e "${ERR} No ID given" && usage 1
    fi
elif [[ $1 =~ ^-(t|-test) ]]; then
    test_port
elif [[ $1 =~ ^-(r|-restart) ]]; then
    if (groups | grep -q sudo); then
        restart_daemon
    else
        echo -e "${ERR} Need to be sudoer" && usage 1
    fi
elif [[ $2 ]]; then
    echo -e "${ERR} Too many arguments" && usage 1
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
else
    show_queue
fi
