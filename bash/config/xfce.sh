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
deb http://deb.debian.org/debian/ ${STABLE} main contrib non-free
#deb-src http://deb.debian.org/debian/ ${STABLE} main contrib non-free
# ${STABLE} security
deb http://deb.debian.org/debian-security/ ${STABLE}-security/updates main contrib non-free
#deb-src http://deb.debian.org/debian-security/ ${STABLE}-security/updates main contrib non-free
# ${STABLE} volatiles
deb http://deb.debian.org/debian/ ${STABLE}-updates main contrib non-free
#deb-src http://deb.debian.org/debian/ ${STABLE}-updates main contrib non-free
# ${STABLE} backports
deb http://deb.debian.org/debian/ ${STABLE}-backports main contrib non-free
#deb-src http://deb.debian.org/debian/ ${STABLE}-backports main contrib non-free
EOF
}

testing_sources(){
    cat <<EOF > /etc/apt/sources.list
# testing
deb http://deb.debian.org/debian/ testing main contrib non-free
#deb-src http://deb.debian.org/debian/ testing main contrib non-free

# testing security
deb http://deb.debian.org/debian-security/ testing-security/updates main contrib non-free
#deb-src http://deb.debian.org/debian-security/ testing-security/updates main contrib non-free
EOF
}

sid_sources(){
    cat <<EOF > /etc/apt/sources.list
# sid
deb http://deb.debian.org/debian/ sid main contrib non-free
#deb-src http://deb.debian.org/debian/ sid main contrib non-free
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

    [[ ${inst_kodi,,} == y ]] && echo "kodi" >> "${usefull}"

    [[ ${inst_steam,,} == y ]] && echo "steam-installer" >> "${usefull}" && add_i386=y

    [[ ${inst_pcsx,,} == y ]] && echo "pcsx2" >> "${usefull}" && add_i386=y

    [[ ${inst_virtmanager,,} == y ]] && echo "virt-manager" >> "${usefull}"

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

    for dotfile in "${SCRIPT_PATH}"/0_dotfiles/root/*; do
        copy_conf "${dotfile}" /root
    done

    if [[ ${allow_root_ssh,,} == y ]]; then
        mkdir -p "${ssh_conf}".d
        echo "PermitRootLogin yes" > "${ssh_conf}".d/allow_root.conf
        systemctl restart ssh
    fi

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

    gruvbox_gtk="${resources}"/gruvbox-arc.xml
    gtk_styles=/usr/share/gtksourceview-4/styles
    cp "${gruvbox_gtk}" "${gtk_styles}"/
}

user_config(){
    dest="$1"

    if [[ ${dest} == /etc/skel ]]; then
        conf_user="future users"
    else
        conf_user="$(basename "${dest}")"
    fi

    echo -e "${NFO} Applying custom configuration for ${conf_user}..."

    for dotfile in "${SCRIPT_PATH}"/0_dotfiles/xfce_user/*; do
        copy_conf "${dotfile}" "${dest}"
    done

    vim +PlugInstall +qall

    autostart_dir="${dest}"/.config/autostart
    mkdir -p "${autostart_dir}"
    cp /usr/share/applications/plank.desktop "${autostart_dir}"/

    for useless_file in .bashrc .bash_logout; do
        rm -f "${dest}"/"${useless_file}"
    done
}

deploy_config(){
    sys_config

    user_config /etc/skel

    echo -e "${OK} Custom XFCE installed"

    users_cpt=0
    systools_cpt=0

    for user_home in /home/*; do
        user="$(basename "${user_home}")"

        if (grep -q ^"${user}:" /etc/passwd); then
            add_grp sudo "${user}"
            [[ ${inst_virtmanager,,} == y ]] && add_grp libvirt "${user}"

            read -rp "Apply configuration to user '${user}' [y/N] ? " -n1 user_conf

            [[ ${user_conf} ]] && echo
            [[ ${user_conf,,} == y ]] && users[${users_cpt}]="${user}" &&
                users_home[${users_cpt}]="${user_home}" && ((users_cpt+=1))
        fi

        git_folder="${user_home}"/Work/git
        [[ -d "${git_folder}" ]] || mkdir -p "${git_folder}"
        chown -R "${user}":"${user}" "${user_home}"/Work

        url_list=("https://github.com/choopsit/my_xfce" \
            "https://github.com/SylEleuth/gruvbox-plus-icon-pack" \
            "https://github.com/SylEleuth/Gruvbox-GTK-Theme")

        for git_url in ${url_list[@]}; do
            git_repo="${git_folder}/${git_url##*/}"
            su -l "${user}" -c "rm -rf ${git_repo}"
            su -l "${user}" -c "git clone ${git_url}.git ${git_repo}"
        done

        my_git_repo="${git_folder}"/my_xfce

        [[ ${systools_cpt} == 0 ]] &&
            "${my_git_repo}"/deployment/deploy_systools.sh && 
            "${my_git_repo}"/bash/scripts/tweak/themeupgrade.sh &&
            ((systools_cpt+=1))

        su -l "${user}" -c "${my_git_repo}/deployment/deploy_user_scripts.sh"
        su -l "${user}" -c "vim +PlugInstall +qall"
    done

    for i in $(seq 0 $((users_cpt-1))); do
        user_config "${users_home[${i}]}"
        user_group="$(awk -F: '/^'"${users[${i}]}"':/{print $5}' /etc/passwd)"
        chown -R "${users[${i}]}":"${user_group//,}" "${users_home[${i}]}"
    done
}

add_grp(){
    group="$1"
    user="$2"

    [[ $(groups "${user}") == *" ${group}"* ]] ||
        read -rp "Add user '${user}' to '${group}' group [y/N] ? " -n1 add_user_to_grp

    [[ ${add_user_to_grp} ]] && echo
    [[ ${add_user_to_grp,,} == y ]] && adduser "${user}" "${group}"

    echo -e "${NFO} '${user}' added to '${group}'"
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

read -rp "Clean sources.list [y/N] ? " -n1 clean_sl
[[ ${clean_sl} ]] && echo


ssh_conf=/etc/ssh/sshd_config
if [[ -f "${ssh_conf}" ]]; then
    (grep -qv ^"PermitRootLogin yes" "${ssh_conf}") ||
        (grep -qv ^"PermitRootLogin yes" "${ssh_conf}".d/*) ||
        read -rp "Allow 'root' on ssh [y/N] ? " -n1 allow_root_ssh
fi

[[ ${allow_root_ssh} ]] && echo

(dpkg -l | grep -q "^ii  kodi ") ||
    read -rp "Install Kodi [y/N] ? " -n1 inst_kodi

[[ ${inst_kodi} ]] && echo

(dpkg -l | grep -q "^ii  steam") ||
    read -rp "Install Steam [y/N] ? " -n1 inst_steam

[[ ${inst_steam} ]] && echo

(dpkg -l | grep -q "^ii  pcsx2") ||
    read -rp "Install PCSX2 [y/N] ? " -n1 inst_pcsx

[[ ${inst_pcsx} ]] && echo

(dpkg -l | grep -q "^ii  virt-manager") && (lspci | grep -qv QEMU) &&
    (dpkg -l | grep -q "^ii  virtualbox ") && (lspci | grep -qiv virtualbox) &&
    read -rp "Install Virtual Machine Manager [y/N] ? " -n1 inst_virtmanager

[[ ${inst_virtmanager} ]] && echo

[[ ${clean_sl,,} == y ]] && clean_sources "${debian_version}"

install_xfce

deploy_config

echo -e "${OK} Custom XFCE installed and configured"

read -rp "Reboot now and enjoy [Y/n] ? " -n1 reboot_now

[[ ${reboot_now} ]] && echo
[[ ${reboot_now,,} == n ]] || reboot
