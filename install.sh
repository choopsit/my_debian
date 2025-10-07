#!/usr/bin/env bash

description="Deploy my personal xfce configuration"
# version: 13.0
# author: Choops <choopsbd@gmail.com>

set -e

stable=trixie
testing=forky

scriptpath="$(dirname "$(realpath "$0")")"


usage() {
    errcode="$1"

    [[ ${errcode} == 0 ]] && echo "${description}" &&
        echo "WRN: It's a combination of personal choices. Use it at your own risk."

    echo "Usage:"
    echo "  ./$(basename "$0") [OPTION]"
    echo "  WRN: Must be run as 'root' or using 'sudo'"
    echo "Options:"
    echo "  -h,--help: Print this help"
    echo

    exit "${errcode}"
}

init_pkglists() {
    base=$1
    useless=$2

    rm -f {${base},${useless}}

    cp -f ${scriptpath}/config/pkg/base ${base} 
    cp -f ${scriptpath}/config/pkg/useless ${useless} 

    if [[ ${debian_version} == sid ]]; then
        echo -e "needrestart\napt-listbugs" >> ${base}
    fi
}

pkgstate() {
    pkg=$1

    if (dpkg -l | grep -q "^ii  ${pkg} "); then
        echo "ON"
    else
        echo "OFF"
    fi
}

gen_checklist() {
    checklist=()

    for app in $@; do
        checklist+=("${app}" "|" "$(pkgstate "${app}")")
    done

    for elt in ${checklist[@]}; do
        echo "${elt}"
    done
}

choose_terminalemulator() {
    term_applist=(
        "terminator"
        "xfce4-terminal" 
        "tilix"
        "kitty"
    )

    term_checklist=$(gen_checklist ${term_applist[@]})

    myterm=($(whiptail --separate-output --radiolist "Terminal-emulator" \
        $((${#term_applist[@]}+8)) 40 ${#term_applist[@]} \
        ${term_checklist[@]} 3>&1 1>&2 2>&3))

    if [[ ${myterm} != "xfce4-terminal" ]]; then
        echo "${myterm}" >> "${mypkg}"
        echo "xfce4-terminal" >> "${uselesspkg}"
    fi
}

select_apps() {
    title=$1
    shift
    applist=($@)

    checklist=$(gen_checklist ${applist[@]})

    myapps=($(whiptail --separate-output --checklist "${title//_/ }" \
        $((${#applist[@]}+8)) 40 ${#applist[@]} \
        ${checklist[@]} 3>&1 1>&2 2>&3))

    for app in ${myapps[@]}; do
        echo -e "${app}" >> "${mypkg}"
    done

    if [[ ${myapps[@]} =~ "transmission-qt" ]]; then
        if [[ ${debian_version} == ${stable} ]]; then
            echo "qt5ct" >> "${mypkg}"
        else
            echo "qt6ct" >> "${mypkg}"
        fi
    fi

    if ! [[ ${myapps[@]} =~ "xfburn" ]]; then
        echo "xfburn" >> "${uselesspkg}"
    fi

    if [[ ${myapps[@]} =~ "gthumb" ]]; then
        echo "ristretto" >> "${uselesspkg}"
    fi

    if [[ ${myapps[@]} =~ "leocad" ]]; then
        echo "ldraw-parts" >> "${mypkg}"
    fi

    if [[ ${myapps[@]} =~ "system-config-printer" ]]; then
        echo "cups" >> "${mypkg}"
    fi

    if [[ ${myapps[@]} =~ "cockpit-machines" ]]; then
        echo "cockpit-pcp" >> "${mypkg}"
    fi
}

choose_systemtools() {
    systools_applist=(
        "xfce4-taskmanager"
        "gparted"
        "deja-dup"
        "qdirstat"
        "hardinfo"
        "gnome-system-monitor"
    )

    select_apps "System_tools" ${systools_applist[@]}
}

choose_accessories() {
    accessorieslist=(
        "galculator"
        "plank"
    )

    select_apps "Accessories" ${accessorieslist[@]}
}

choose_internetapps() {
    internet_applist=(
        "proton-vpn-gnome-desktop"
        "qbittorrent"
        "transmission-qt"
        "thunderbird"
        "chromium"
        "remmina"
    )

    select_apps "Internet_applications" ${internet_applist[@]}
}

choose_multimediaapps() {
    multimedia_applist=(
        "clapper"
        "kodi"
        "xfburn"
        "soundconverter"
        "sound-juicer"
        "kdenlive"
        "obs-studio"
        "audacity"
        "hydrogen"
        "lollypop"
        "mpv"
        "vlc"
    )

    select_apps "Multimedia_applications" ${multimedia_applist[@]}
}

choose_graphicsapps() {
    graphics_applist=(
        "gthumb"
        "gimp"
        "blender"
        "inkscape"
        "mypaint"
        "krita"
        "simple-scan"
    )

    select_apps "Graphics_applications" ${graphics_applist[@]}
}

choose_officeapps() {
    office_applist=(
        "system-config-printer"
        "zim"
        "evince"
    )

    select_apps "Office_applications" ${office_applist[@]}
}

choose_games() {
    gameslist=(
        "steam-installer"
        "dolphin-emu"
        "supertuxkart"
        "quadrapassel"
        "gnome-2048"
        "pcsx2:i386"
        "mednaffe"
        "0ad"
        "pokerth"
    )
    #TODO:
    #add RPCS3:
    #dep: libfuse2t64
    #install from github

    select_apps "Games" ${gameslist[@]}
}

choose_scienseapps() {
    science_applist=(
        "stellarium"
        "leocad"
        "freecad"
    )

    select_apps "Sience_applications" ${science_applist[@]}
}

choose_virtualizationtools() {
    virt_applist=(
        "virt-manager"
        "cockpit-machines"
        "gnome-boxes"
    )

    select_apps "Virtualization_tools" ${virt_applist[@]}
}

choose_services() {
    serviceslist=(
        "openssh-server"
        "nfs-kernel-server"
    )

    select_apps "Services" ${serviceslist[@]}
}

choose_components() {
    choose_terminalemulator
    choose_systemtools
    choose_accessories
    choose_internetapps
    choose_multimediaapps
    choose_graphicsapps
    choose_officeapps
    choose_games
    choose_scienseapps
    choose_virtualizationtools
    choose_services
}

check_add_user_to() {
    local usr="$1"
    local grp="$2"

    add2grp_title="Privileges elevation"
    add2grp_text="Add user '${usr}' to '${grp}' group ?"
    if (whiptail --title "${add2grp_title}" --yesno "${add2grp_text}" 8 78); then
        groups2add[${usr}]+="${grp} "
    fi
}

elevation() {
    local usr="$1"

    if ! (groups "${usr}" | grep -q sudo); then
        check_add_user_to "${usr}" sudo
    fi

    if grep -q 'virt\|cockpit' "${mypkg}" && ! (groups "${usr}" | grep -q libvirti); then
        check_add_user_to "${usr}" libvirt
    fi
}

apply_perso() {
    local usr="$1"

    cfg_title="User configuration"
    cfg_text="Apply personalization to ${usr}'s profile ?"
    if (whiptail --title "${cfg_title}" --yesno "${cfg_text}" 8 78); then
        okconf_users+="${usr}"
    fi
}

user_config_menu() {
    usrcfg_title="user config"
    softs_text="apply xfce config for '${user}' ?"

    for user_home in /home/*; do
        user="$(basename "${user_home}")"

        if (grep -q ^"${user}:" /etc/passwd); then
            elevation "${user}"
            apply_perso "${user}"
        fi
    done
}

stable_sources() {
    echo "Types: deb
URIs: http://deb.debian.org/debian
Suites: ${stable} ${stable}-updates ${stable}-backports
Components: main contrib non-free non-free-firmware
Architectures: amd64 i386
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://deb.debian.org/debian-security
Suites: ${stable}-security
Components: main contrib non-free non-free-firmware
Architectures: amd64 i386
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" > /etc/apt/sources.list.d/${stable}.sources
}

testing_sources() {
    echo "Types: deb
URIs: http://deb.debian.org/debian
Suites: testing
Components: main contrib non-free non-free-firmware
Architectures: amd64 i386
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://deb.debian.org/debian-security
Suites: testing-security
Components: main contrib non-free non-free-firmware
Architectures: amd64 i386
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" > /etc/apt/sources.list.d/testing.sources
}

sid_sources() {
    echo "Types: deb
URIs: http://deb.debian.org/debian
Suites: sid
Components: main contrib non-free non-free-firmware
Architectures: amd64 i386
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" > /etc/apt/sources.list.d/sid.sources
}

renew_sources() {
    echo "Renewng sources (deb288 format)..."

    rm -f /etc/apt/sources.list

    if [[ ${debian_version} == sid ]]; then
        sid_sources
    elif [[ ${debian_version} == ${stable} ]]; then
        stable_sources
    else
        testing_sourcesd
    fi
}

copy_conf() {
    local src="$1"
    local dst="$2"

    if [[ -f "${src}" ]]; then
        cp "${src}" "${dst}"/."$(basename "${src}")"
    elif [[ -d "${src}" ]]; then
        mkdir -p  "${dst}"/."$(basename "${src}")"
        cp -r "${src}"/* "${dst}"/."$(basename "${src}")"/
    fi
}

user_config() {
    myuser=$1

    myhome="/home/${myuser}"

    [[ ${myuser} = root ]] && myhome=/etc/skel

    echo "Applying custom config to '${myhome}'..."

    for dotfile in "${scriptpath}"/config/dotfiles/skel/*; do
        copy_conf "${dotfile}" "${myhome}"
    done

    if [[ ${myuser} != root ]]; then
        chown -R "${myuser}":"${myuser}" "${myhome}"

        vimplug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        vimplug_dest="${myhome}/.vim/autoload/plug.vim "

        su -l "${myuser}" -c "curl -fLo ${vimplug_dest} --create-dirs ${vimplug_url}"
        su -l "${myuser}" -c "vim +PlugInstall +qall"

        my_git_url="https://github.com/choopsit/my_debian.git"
        git_folder="${myhome}"/Work/git
        my_git_repo="${git_folder}"/my_debian

        su -l "${myuser}" -c "mkdir -p ${git_folder}"

        if [[ -d "${my_git_repo}" ]]; then
            su -l "${myuser}" -c "cd ${my_git_repo} && git pull"
        else
            su -l "${myuser}" -c "git clone ${my_git_url} ${my_git_repo}"
        fi

        su -l "${myuser}" -c "${my_git_repo}/deployment/deploy_user_scripts.sh"
    fi

    for obsolete_dotfile in .bashrc .bash_logout .vimrc .vim_info; do
        rm -f "${myhome}/${obsolete_dotfile}"
    done
}

lightdm_config() {
    echo "[Seat:*]
greeter-hide-users=false
user-session=xfce
[Greeter]
draw-user-backgrounds=true" > /usr/share/lightdm/lightdm.conf.d/10_my.conf
}

redshift_config() {
    echo "
[redshift]
allowed=true
system=false
users=" >> /etc/geoclue/geoclue.conf
}

pulse_config() {
    pulse_param="flat-volumes = no"
    pulse_conf=/etc/pulse/daemon.conf
    if (grep -q ^"${pulse_param}" "${pulse_conf}"); then
        sed -e "s/; ${pulse_param}/${pulse_param}/" -i "${pulse_conf}"
    fi
}

theming() {
    cp "${scriptpath}"/config/resources/*.xml /usr/share/gtksourceview-4/styles/

    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -t Papirus-Dark -C yaru

    "${scriptpath}"/scripts/tweak/themeupgrade.sh
}

root_config() {
    my_conf=("skel/profile" "skel/vim" "root/bashrc")
    for conf in "${my_conf[@]}"; do
        copy_conf "${scriptpath}/config/dotfiles/${conf}" /root
    done

    vimplug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    curl -fLo /root/.vim/autoload/plug.vim --create-dirs "${vimplug_url}"
    vim +PlugInstall +qall
}

system_config() {
    lightdm_config

    (grep -qvs redshift /etc/geoclue/geoclue.conf) && redshift_config

    pulse_config

    root_config

    "${scriptpath}"/deployment/deploy_systools.sh
}

install() {
    echo "Starting installation..."

    if (grep -q "proton-vpn-gnome-desktop" "${mypkg}"); then
        if ! (dpkg -l | grep -q "protonvpn-stable-release"); then
            apt update
            apt install -y gnupg
            proton_srcpkg="protonvpn-stable-release_1.0.8_all.deb"
            proton_repo="https://repo.protonvpn.com/debian/dists/stable/main/binary-all"
            wget -O "/tmp/${proton_srcpkg}" "${proton_repo}/${proton_srcpkg}"
            dpkg -i "/tmp/${proton_srcpkg}"
        fi
    fi

    dpkg --add-architecture i386
    apt update
    apt full-upgrade -y
    xargs apt install -y < "${mypkg}"
    xargs apt purge -y < "${uselesspkg}"
    apt autoremove --purge -y

    system_config
    theming
    user_config root
}


[[ $2 ]] && echo -e "${ERR} Too many arguments" && usage 1

if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

if [[ $(whoami) != root ]]; then
    echo -e "ERR: Need higher privileges"
    exit 1
fi

my_dist="$(awk -F= '/^ID=/{print $2}' /etc/os-release)"

if [[ ${my_dist} != debian ]]; then
    echo "ERR: $(basename "$0") works only on Debian"
    exit 1
fi

debian_version="$(lsb_release -sc)"

if [[ ${debian_version} == "${testing}" ]]; then
    if [[ -f /etc/apt/sources.list ]]; then
        for vers in sid unstable; do
            grep -q "^deb .*${vers}" /etc/apt/sources.list && debian_version=sid
        done
    fi

    for sourcesfile in /etc/apt/sources.list.d/*; do
        (grep -qE "sid|unstable" "${sourcesfile}" ) && debian_version=sid
    done
fi

if ! [[ "${stable} ${testing} sid" =~ (\ |^)${debian_version}(\ |$) ]]; then
    echo "ERR: Unsupported version '${debian_version}'"
    exit 1
else
    echo "OS detected: Debian ${debian_version}"
fi

mypkg=/tmp/mypkg
uselesspkg=/tmp/uselesspkg
init_pkglists "$mypkg" "$uselesspkg"

choose_components

okconf_users=()
groups2ad=()
user_config_menu

renewsources=n
sources_text="Refresh apt sources (deb288 format) ?\nWARNING: Third party repos may be removed"
if (whiptail --yesno "${sources_text}" 8 78); then
    renewsources=y
fi

ready_text="Ready to go ?"
if (whiptail --yesno "${ready_text}" 8 78); then
    [[ ${renewsources} == y ]] && renew_sources

    install

    for usr in ${okconf_users[@]}; do
        user_config  "${usr}"
    done

    for usr_home in /home/*; do
        usr="$(basename "${usr_home}")"

        for grp in ${groups2add[${usr}]}; do
            adduser "${usr}" "${grp}"
        done
    done
else
    exit 0
fi

if (whiptail --yesno "Reboot and enjoy ?" 8 78); then
    reboot
else
    exit 0
fi
