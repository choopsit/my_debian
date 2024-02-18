#!/usr/bin/env bash

set -e

description="Backup user config and more in /volumes/backup"
# version: 12.1
# author: "Choops <choopsbd@gmail.com>

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

DEST_ROOT=/volumes/backup
DEST_BKP="${DEST_ROOT}/$(date +"%y%m")_${USER}-on-$(hostname -s)"


usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo -e "${CYN}${description}${DEF}"
    echo -e "${CYN}Usage${DEF}:"
    echo -e "  $(basename "$0") <OPTION>"
    echo -e "${CYN}Options${DEF}:"
    echo -e "  -h,--help:     Print this help"
    echo -e "  -v,--versbose: Add verbosity"
    echo

    exit "${errcode}"
}

mount_backup_dest() {
    ! (groups | grep -q sudo) &&
        echo "${ERR} ${USER} cannot mount ${DEST_ROOT}. Need 'sudo' rights" &&
        exit 1

    read -p "Mount ${DEST_ROOT} [y/N] ?" -rn1 mnt_dest
    [[ ${mnt_dest} ]] && echo
    [[ ${mnt_dest,,} != y ]] && exit 0
    sudo mount "${DEST_ROOT}"
}

umount_backup_dest() {
    if (groups | grep -q sudo); then
        read -p "Unmount ${DEST_ROOT} [Y/n] ?" -rn1 umnt_dest
        [[ ${umnt_dest} ]] && echo
        [[ ${umnt_dest,,} != n ]] && sudo umount "${DEST_ROOT}"
    fi
}

rsync_bkp() {
    src="$1"

    src_path="$(realpath --no-symlinks "${src}")"
    src_parent="$(dirname "${src_path}")"

    if [[ -e "${src_path}" ]]; then
        tgt="${DEST_BKP}${src_parent}"
        mkdir -p "${tgt}"
        rsync -Oatzulr --delete --exclude '*~' "${src_path}" "${tgt}"/ ||
            echo -e "${WRN} Error(s) happend backuping ${src}"

        if [[ ${VERBOSE} ]]; then
            echo -e "${GRY}[$(date +"%d %b %Y - %R:%S")]${DEF} Backup of '${src_path}' done"
        fi
    fi
}

home_backup() {
    home_bkp="${DEST_BKP}${HOME}"

    echo -e "${NFO} Backuping '${YLO}${HOME}${DEF}' to '${YLO}${home_bkp}${DEF}'..."

    elements_to_backup=(".config" ".gnupg" ".kodi" ".vim" ".mozilla" ".steam" \
        ".pcsxr" ".face" ".local/bin" ".local/share" ".face" ".profile" \
        "Documents" "Pictures" "Videos" "Templates" "Work" "Games" \
        "Images" "Vidéos" "Modèles" "Jeux")

    for element in "${elements_to_backup[@]}"; do
        rsync_bkp "${HOME}/${element}"
    done
}

sysconf_backup() {
    echo -e "${NFO} Backuping ${YLO}system configurations${DEF} to '${YLO}${DEST_BKP}/${DEF}'..."

    elements_to_backup=("/etc/apt/sources.list" "/etc/apt/sources.list.d" \
        "/etc/skel" "/etc/fstab" "/etc/exports" "/etc/pulse/daemon.conf" \
        "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.d" "/etc/X11" \
        "/etc/sysctl.d/99-swappiness.conf" \
        "/usr/share/X11/xorg.conf.d/10-nvidia.conf" \
        "/usr/share/lightdm/lightdm.conf.d/10_my.conf" \
        "/usr/share/gtksourceview-4/styles")

    for element in "${elements_to_backup[@]}"; do
        rsync_bkp "${element}"
    done
}

spec_backup() {
    src_folder="$1"

    echo -e "${NFO} Backuping '${YLO}${src_folder}${DEF}' to '${YLO}${DEST_BKP}/${DEF}'..."
    rsync_bkp "${src_folder}"
}


if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 =~ ^-(v|-verbose)$ ]]; then
    VERBOSE=true
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

! (dpkg -l | grep -q rsync) &&
    echo -e "${ERR} 'rsunc' needed but not installed\n" && exit 1

[[ ! -d ${DEST_ROOT} ]] &&
    echo -e "${ERR} ${DEST_ROOT} mount point does not exist\n" && exit 1

mnt_dest=""
if ! (mount | grep -q " ${DEST_ROOT} "); then
    echo -e "${WRN} ${DEST_ROOT} not mounted\n"
    mount_backup_dest
fi

home_backup

sysconf_backup

if [[ $(hostname) == mrchat ]]; then
    for spec_src in "potatoe/Music" "potatoe/Work" "speedix/roms"; do
        [[ -d "/volumes/${spec_src}" ]] && spec_backup "/volumes/${spec_src}"
    done
fi

[[ ${mnt_dest,,} == y ]] && umount_backup_dest

echo
