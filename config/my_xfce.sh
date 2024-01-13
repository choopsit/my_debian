#!/usr/bin/env bash

description="Deploy my personal xfce configuration"
# version: 12.1
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
    # TODO FIRST:
    # checkboxes list
}

games_menu(){
    games_title="Games"
    # TODO:
    # checkboxes list
}

usrcfg_menu(){
    usrcfg_title="User config"
    # TODO:
    # successive yes/no
}

config_menus(){
    clsrc_menu
    softs_menu
    games_menu
    usrcfg_menu
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

sys_update(){
    echo -e "${NFO} Upgrading system..."
    apt update
    apt upgrade -y
    apt full-upgrade -y
}

install_packages(){
    usefull=/tmp/usefull_pkgs
    useless=/tmp/useless_pkgs
    pkg_lists="${SCRIPT_PATH}"/pkg

    cp "${pkg_lists}"/xfce_base "${usefull}"
    cp "${pkg_lists}"/xfce_useless "${useless}"

    add_i386=n

    [[ ${debian_version} == sid ]] &&
        echo -e "firefox\napt-listbugs\nneedrestart" >> "${usefull}" &&
        echo -e "firefox-esr\nzutty" >> "${useless}"

    (lspci | grep -q NVIDIA) && echo "nvidia-driver" >> "${usefull}" && add_i386=y

    # TODO:
    # add packages returned by menus to "$usefull"

    [[ ${add_i386,,} == y ]] && dpkg --add-architecture i386

    sys_update

    echo -e "${NFO} Installing new packages then removing useless ones..."

    xargs apt install -y < "${usefull}"

    xargs apt purge -y < "${useless}"

    apt autoremove --purge -y
}

copy_conf(){
    src="$1"
    dst="$2"

    if [[ -f "${src}" ]]; then
        cp "${src}" "${dst}"/."$(basename "${src}")"
    elif [[ -d "${src}" ]]; then
        mkdir -p  "${dst}"/."$(basename "${src}")"
        cp -r "${src}"/* "${dst}"/."$(basename "${src}")"/
    fi
}

user_config(){
    dest="$1"

    if [[ ${dest} == /etc/skel ]]; then
        conf_user="future users"
    else
        conf_user="$(basename "${dest}")"
    fi

    echo -e "${NFO} Applying custom configuration for ${conf_user}..."

    for dotfile in "${SCRIPT_PATH}"/dotfiles/skel/*; do
        copy_conf "${dotfile}" "${dest}"
    done

    if [[ ${conf_user} != "future users" ]]; then
        chown -R "${conf_user}":"${conf_user}" "${dest}"

        vimplug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

        su -l "${conf_user}" -c "
        mkdir -p ${dest}/.vim/autoload
        wget -O ${dest}/.vim/autoload/plug.vim ${vimplug_url}
        vim +PlugInstall +qall
        "

        my_git_url="https://github.com/choopsit/my_debian.git"
        git_folder="${dest}"/Work/git
        my_git_repo="${git_folder}"/my_debian

        su -l "${conf_user}" -c "mkdir -p ${git_folder}"

        if [[ -d "${my_git_repo}" ]]; then
            su -l "${conf_user}" -c "cd ${my_git_repo}; git pull"
        else
            su -l "${conf_user}" -c "git clone ${my_git_url} ${my_git_repo}"
        fi

        su -l "${conf_user}" -c "${my_git_repo}/deployment/deploy_user_scripts.sh"
    fi

    for useless_file in .bashrc .bash_logout .vimrc .vim_info; do
        rm -f "${dest}/${useless_file}"
    done
}

lightdm_config(){
    cat <<EOF > "${lightdm_conf}"
[Seat:*]
greeter-hide-users=false
user-session=xfce
[Greeter]
draw-user-backgrounds=true
EOF
}

sys_config(){
    echo -e "${NFO} Applying custom system configuration..."

    my_conf=("skel/profile" "skel/vim" "root/bashrc")
    for conf in "${my_conf[@]}"; do
        copy_conf "${SCRIPT_PATH}/dotfiles/${conf}" /root
    done

    vimplug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    mkdir -p /root/.vim/autoload
    wget -O /root/.vim/autoload/plug.vim "${vimplug_url}"

    vim +PlugInstall +qall

    pulse_param="flat-volumes = no"
    pulse_conf=/etc/pulse/daemon.conf
    (grep -q ^"${pulse_param}" "${pulse_conf}") &&
        sed -e "s/; ${pulse_param}/${pulse_param}/" -i "${pulse_conf}"

    lightdm_conf=/usr/share/lightdm/lightdm.conf.d/10_my.conf
    [[ -f "${lightdm_conf}" ]] || lightdm_config

    redshift_conf=/etc/geoclue/geoclue.conf
    (grep -qvs redshift "${redshift_conf}") &&
        echo -e "\n[redshift]\nallowed=true\nsystem=false\nusers=" >> "${redshift_conf}"

    resources="${SCRIPT_PATH}"/resources

    gtk_styles=/usr/share/gtksourceview-4/styles
    cp "${resources}"/*.xml "${gtk_styles}"/

    user_config /etc/skel
}

apply_config(){
    [[ ${clsrc} == y ]] && clean_sources

    install_packages

    sys_config

    for sudouser in ${newsudo[@]}; do
        adduser "${sudouser}" sudo
    done

    for libvirtuser in ${newlibvirt[@]}; do
        adduser "${libvirtuser}" libvirt
    done

    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -t Papirus-Dark -C yaru
    "${SCRIPT_PATH}"/../scripts/tweak/themeupgrade.sh
    "${SCRIPT_PATH}"/../deployment/deploy_systools.sh

    # TODO:
    # deploy user config for users chosen from menus
    for i in $(seq 0 $((users_cpt-1))); do
        user_config "${users_home[${i}]}"
    done
}

end_menu() {
    reboot_title="Custom XFCE installed and configured"
    reboot_text="Reboot now and enjoy ? "
    (whiptail --title "${reboot_title}" --yesno "${reboot_text}" 8 78) && reboot
    exit 0
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

# quit
end_menu
