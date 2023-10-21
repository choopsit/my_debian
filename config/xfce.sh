#!/usr/bin/env bash

description="Deploy my personal xfce configuration"
# version: 12.0
# author: Choops <choopsbd@gmail.com>

set -e

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
    if [[ ${version} == sid ]]; then
        sid_sources
    elif [[ ${version} == "${STABLE}" ]]; then
        stable_sources
    elif [[ ${version} == "${TESTING}" ]]; then
        testing_sources
    else
        echo -e "${ERR} Unsupported version '${version}'"
        exit 1
    fi
}

sys_update(){
    echo -e "${NFO} Upgrading system..."
    apt update || { echo -e "${RED}WTF !!!${DEF}" && exit 1; }
    apt upgrade -y
    apt full-upgrade -y
}

install_xfce(){
    usefull=/tmp/usefull_pkgs
    useless=/tmp/useless_pkgs
    pkg_lists="${SCRIPT_PATH}"/1_pkg

    cp "${pkg_lists}"/xfce_base "${usefull}"
    cp "${pkg_lists}"/xfce_useless "${useless}"

    add_i386=n

    [[ ${debian_version} == sid ]] &&
        echo -e "firefox\napt-listbugs\nneedrestart" >> "${usefull}" &&
        echo -e "firefox-esr\nzutty" >> "${useless}"

    (lspci | grep -q NVIDIA) && echo "nvidia-driver" >> "${usefull}" && add_i386=y

    [[ ${inst_virtmanager,,} == y ]] && echo "virt-manager" >> "${usefull}"

    [[ ${inst_kodi,,} == y ]] && echo "kodi" >> "${usefull}"

    [[ ${inst_games,,} == y ]] && echo -e "gnome-2048\nquadrapassel" >> "${usefull}"

    [[ ${inst_steam,,} == y ]] && echo "steam-installer" >> "${usefull}" && add_i386=y

    [[ ${inst_pcsx,,} == y ]] && echo "pcsx2" >> "${usefull}" && add_i386=y

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
        copy_conf "${SCRIPT_PATH}/0_dotfiles/${conf}" /root
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

    resources="${SCRIPT_PATH}"/2_resources

    gtk_styles=/usr/share/gtksourceview-4/styles
    cp "${resources}"/*.xml "${gtk_styles}"/
}

user_config(){
    dest="$1"

    if [[ ${dest} == /etc/skel ]]; then
        conf_user="future users"
    else
        conf_user="$(basename "${dest}")"
    fi

    echo -e "${NFO} Applying custom configuration for ${conf_user}..."

    for dotfile in "${SCRIPT_PATH}"/0_dotfiles/skel/*; do
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

deploy_config(){
    sys_config

    for sudouser in ${newsudo[@]}; do
        adduser "${sudouser}" sudo
    done

    for libvirtuser in ${newlibvirt[@]}; do
        adduser "${libvirtuser}" libvirt
    done

    user_config /etc/skel

    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -t Papirus-Dark -C yaru
    "${SCRIPT_PATH}"/../scripts/tweak/themeupgrade.sh
    "${SCRIPT_PATH}"/../deployment/deploy_systools.sh

    for i in $(seq 0 $((users_cpt-1))); do
        user_config "${users_home[${i}]}"
    done
}

feed_config(){
    clear
    read -rp "Clean sources.list [Y/n] ? " -n1 clean_sl
    [[ ${clean_sl} ]] && echo

    (dpkg -l | grep -q "^ii  virt-manager") && (lspci | grep -qv QEMU) &&
        (dpkg -l | grep -q "^ii  virtualbox ") && (lspci | grep -qiv virtualbox) &&
        read -rp "Install Virtual Machine Manager [y/N] ? " -n1 inst_virtmanager

    [[ ${inst_virtmanager} ]] && echo

    (dpkg -l | grep -q "^ii  kodi ") ||
        read -rp "Install Kodi [y/N] ? " -n1 inst_kodi

    [[ ${inst_kodi} ]] && echo

    read -rp "Install games [y/N] ? " -n1 inst_games
    [[ ${inst_games} ]] && echo

    if [[ ${inst_games,,} == y ]]; then
        (dpkg -l | grep -q "^ii  steam") ||
            read -rp "Install Steam [y/N] ? " -n1 inst_steam

        [[ ${inst_steam} ]] && echo

        (dpkg -l | grep -q "^ii  pcsx2") ||
            read -rp "Install PCSX2 [y/N] ? " -n1 inst_pcsx

        [[ ${inst_pcsx} ]] && echo
    fi

    users_cpt=0
    newsudo=()
    newlibvirt=()

    for user_home in /home/*; do
        user="$(basename "${user_home}")"

        if (grep -q ^"${user}:" /etc/passwd); then
            read -rp "Add user '${user}' to 'sudo' group [Y/n] ? " -n1 add_user_to_sudo
            [[ ${add_user_to_sudo} ]] && echo
            [[ ${add_user_to_sudo,,} != n ]] && newsudo+=("${user}")

            if [[ ${inst_virtmanager,,} == y ]]; then
                read -rp "Add user '${user}' to 'libvirt' group [Y/n] ? " -n1 add_user_to_libvirt
                [[ ${add_user_to_libvirt} ]] && echo
                [[ ${add_user_to_libvirt,,} != n ]] && newlibvirt+=("${user}")
            fi

            read -rp "Apply configuration to user '${user}' [Y/n] ? " -n1 user_conf

            [[ ${user_conf} ]] && echo
            [[ ${user_conf,,} != n ]] && users[${users_cpt}]="${user}" &&
                users_home[${users_cpt}]="${user_home}" && ((users_cpt+=1))
        fi
    done
}


[[ $2 ]] && echo -e "${ERR} Too many arguments" && usage 1
if [[ $1 =~ ^-(h|-help)$ ]]; then
    usage 0
elif [[ $1 ]]; then
    echo -e "${ERR} Bad argument" && usage 1
fi

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

feed_config

[[ ${clean_sl,,} != n ]] && clean_sources "${debian_version}"

install_xfce

deploy_config

clear
echo -e "${OK} Custom XFCE installed and configured"

read -rp "Reboot now and enjoy [Y/n] ? " -n1 reboot_now

[[ ${reboot_now} ]] && echo
[[ ${reboot_now,,} == n ]] || reboot
