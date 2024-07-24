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
radiolist=black,blue
label=black,blue
checkbox=black,white
compactbutton=black,lightgray
button=white,red"


usage() {
    local errcode="$1"

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

stable_sources() {
    cat <<eof > /etc/apt/sources.list
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
eof
}

testing_sources() {
    cat <<eof > /etc/apt/sources.list
# testing
deb http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian/ testing main contrib non-free non-free-firmware

# testing security
deb http://deb.debian.org/debian-security/ testing-security/updates main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian-security/ testing-security/updates main contrib non-free non-free-firmware
eof
}

sid_sources() {
    cat <<eof > /etc/apt/sources.list
# sid
deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware 
eof
}

clean_sources() {
    local version="$1"

    echo -e "${nfo} cleaning sources.list..."
    if [[ ${version} == "${STABLE}" ]]; then
        stable_sources
    elif [[ ${version} == "${TESTING}" ]]; then
        testing_sources
    else
        sid_sources
    fi
}

clean_sources_menu() {
    clsrc_title="Clean sources.list"
    clsrc_text="Modify /etc/apt/sources.list to include properly all needed branches ?"
    (whiptail --title "${clsrc_title}" --yesno "${clsrc_text}" 8 78) && clean_sources
}

init_pkglists() {
    usefull=/tmp/usefull_pkgs
    useless=/tmp/useless_pkgs
    pkg_lists="${SCRIPT_PATH}"/pkg

    rm -f "${usefull}"
    rm -f "${useless}"

    cp "${pkg_lists}"/xfce_base "${usefull}"
    cp "${pkg_lists}"/xfce_useless "${useless}"
}

get_longest_elt_length() {
    echo "$@" | sed "s/ /\n/g" | wc -L
}

max() {
    echo -e "$1\n$2" | sort -n | tail -1
}

replicate() {
    local n="$1"
    local pattern="$2"
    local str

    for _ in $(seq 1 "$n"); do
        str="${str}${pattern}"
    done
    echo "${str}"
}

feed_checkboxes() {
    local my_list=("$@")

    for i in $(seq 0 2 ${#my_list[@]}); do
        [[ $i -ge ${#my_list[@]} ]] && continue

        key="${my_list[$i]}"
        value="${my_list[$((i + 1))]}"
        [[ ${value} ]] || value="${key}"

        checkboxes["${key}"]="${value}"
    done
}

add_apps() {
    local my_title=$1
    shift
    local my_text=$1
    shift
    local chkbx_src=("$@")

    unset checkboxes
    declare -A checkboxes

    feed_checkboxes "${chkbx_src[@]}"

    choices=()
    local maxlen
    maxlen="$(get_longest_elt_length "${!checkboxes[@]}")"
    linesize="$(max "${maxlen}" 42)"
    local spacer
    spacer="$(replicate "$((linesize - maxlen))" " ")"

    for key in "${!checkboxes[@]}"; do
        readarray -t my_pkgs < <(printf '%b\n' "${checkboxes[${key}]}")
        primary_pkg="${my_pkgs[0]}"
        if (dpkg -l | grep -q "^ii  ${primary_pkg}"); then
            choices+=("${key}" "${spacer}" "ON")
        else
            choices+=("${key}" "${spacer}" "OFF")
        fi
    done

    dialogwheight="$((${#checkboxes[@]} + 8))"
    dialogwidth="$((linesize + 12))"
    checklistheight="${#checkboxes[@]}"

    result=$(
    whiptail --title "${my_title}" \
        --checklist "${my_text}" \
        "${dialogheight}" "${dialogwidth}" "${checklistheight}" \
        "${choices[@]}" \
        3>&2 2>&1 1>&3
    )
    [[ $? != 0 ]] && exit 1

    programs=$(echo "${result}" | sed 's/" /\n/g' | sed 's/"//g')

    while IFS= read -r pgm; do
        [[ ${pgm} ]] && echo -e "${checkboxes["${pgm}"]}" >> "${usefull}"
    done <<< "${programs}"
}

virtualization_menu() {
    virt_title="Virtualization"
    virt_text="Choose Virtual machines manager(s) you want to install"

    virt=(
        "virt-manager" ""
        "cockpit-images" "cockpit\ncockpit-machines\ncockpit-pcp"
    )

    add_apps "${virt_title}" "${virt_text}" "${virt[@]}"
}

applications_adding_menu() {
    init_pkglists

    if ! (dpkg -l | grep -q "^ii  openssh-server"); then
        ssh_title="ssh server"
        ssh_text="Install openssh-server ?"
        if (whiptail --title "${ssh_title}" --yesno "${ssh_text}" 8 78); then
            echo "openssh-server" >>"${usefull}"
        fi
    fi

    swterm_title="Terminal emulator"
    swterm_text="Use terminator instead of xfce-terminal ?"
    if (whiptail --title "${swterm_title}" --yesno "${swterm_text}" 8 78); then
        echo "terminator" >>"${usefull}"
        echo "xfce4-terminal" >>"${useless}"
    fi

    tools_title="Tools"
    tools_text="Choose tool(s) you want to install"

    # list: key1 packages1 key2 packages2 key3 packages3... to feed checkboxes
    # if packages# = key# then packages# can be "" to simplify additions
    tools=(
        "flameshot" ""
        "gnome-system-monitor" ""
        "galculator"
    )

    add_apps "${tools_title}" "${tools_text}" "${tools[@]}"

    nets_title="Internet and security"
    nets_text="Choose internet and security application(s) you want to install"

    nets=(
        "chromium" ""
        "deluge" ""
        "transmission-qt" "transmission-qt\n${qtct}"
        "keepassxc" "keepassxc-full\nwebext-keepassxc-browser"
    )

    add_apps "${nets_title}" "${nets_text}" "${nets[@]}"

    media_title="Multimedia"
    media_text="Choose multimedia application(s) you want to install"

    media=(
        "kodi" "kodi\nkodi-inputstream-adaptive"
        "lollypop" ""
        "kdenlive" ""
        "soundconverter" ""
        "sound-juicer" ""
        "audacity" ""
    )

    add_apps "${media_title}" "${media_text}" "${media[@]}"

    graph_title="Graphics"
    graph_text="Choose graphics tool(s) you want to install"

    graph=(
        "gimp" ""
        "blender" ""
        "inkscape" ""
    )

    add_apps "${graph_title}" "${graph_text}" "${graph[@]}"

    (systemd-detect-virt >/dev/null) || virtualization_menu

    games_title="Games"
    games_text="Choose game(s) you want to install"

    #TODO:
    #add RPCS3:
    #"rpcs3" "libfuse2t64"
    #install from github
    games=(
        "steam" "steam-installer"
        "pcsx2" ""
        "mednaffe" ""
        "supertuxkart" ""
        "0ad" ""
        "quadrapassel" ""
        "gnome-2048" ""
        "pokerth" ""
    )

    add_apps "${games_title}" "${games_text}" "${games[@]}"

    sci_title="Science"
    sci_text="Choose science/educational application(s) you want to install"

    sci=(
        "leocad" ""
        "freecad" ""
        "stellarium" ""
    )

    add_apps "${sci_title}" "${sci_text}" "${sci[@]}"
}

sys_update() {
    echo -e "${nfo} upgrading system..."
    apt update
    apt upgrade -y
    apt full-upgrade -y
}

install_packages() {
    add_i386=n

    [[ ${debian_version} == sid ]] &&
        echo -e "firefox\napt-listbugs\nneedrestart" >> "${usefull}" &&
        echo -e "firefox-esr\nzutty" >> "${useless}"

    (lspci | grep -qi nvidia) && add_i386=y && echo "nvidia-driver" >> "${usefull}"

    grep -q "pcsx2" "${usefull}" && add_i386=y

    [[ ${add_i386,,} == y ]] && dpkg --add-architecture i386

    sys_update

    echo -e "${nfo} installing new packages then removing useless ones..."

    xargs apt install -y < "${usefull}"

    xargs apt purge -y < "${useless}"

    apt autoremove --purge -y
}

lightdm_config() {
    cat <<EOF > "${lightdm_conf}"
[Seat:*]
greeter-hide-users=false
user-session=xfce
[Greeter]
draw-user-backgrounds=true
EOF
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
    local dest="$1"

    if [[ ${dest} == /etc/skel ]]; then
        conf_user="future users"
    else
        conf_user="$(basename "${dest}")"
    fi

    echo -e "${nfo} applying custom configuration for ${conf_user}..."

    for dotfile in "${SCRIPT_PATH}"/dotfiles/skel/*; do
        copy_conf "${dotfile}" "${dest}"
    done

    [[ ${debian_version} == sid ]] && rm -rf "${dest}/.config/xfce4/terminal"

    sed "s/qt6ct/${qtct}/g" "${dest}/.profile"
    if [[ ${conf_user} != "future users" ]]; then
        chown -R "${conf_user}":"${conf_user}" "${dest}"

        vimplug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        vimplug_dest="${dest}/.vim/autoload/plug.vim "

        su -l "${conf_user}" -c "curl -fLo ${vimplug_dest} --create-dirs ${vimplug_url}"
        su -l "${conf_user}" -c "vim +PlugInstall +qall"

        my_git_url="https://github.com/choopsit/my_debian.git"
        git_folder="${dest}"/Work/git
        my_git_repo="${git_folder}"/my_debian

        su -l "${conf_user}" -c "mkdir -p ${git_folder}"

        if [[ -d "${my_git_repo}" ]]; then
            su -l "${conf_user}" -c "cd ${my_git_repo} && git pull"
        else
            su -l "${conf_user}" -c "git clone ${my_git_url} ${my_git_repo}"
        fi

        su -l "${conf_user}" -c "${my_git_repo}/deployment/deploy_user_scripts.sh"
    fi

    for obsolete_dotfile in .bashrc .bash_logout .vimrc .vim_info; do
        rm -f "${dest}/${obsolete_dotfile}"
    done
}

system_config() {
    echo -e "${NFO} Applying custom system configuration..."

    my_conf=("skel/profile" "skel/vim" "root/bashrc")
    for conf in "${my_conf[@]}"; do
        copy_conf "${SCRIPT_PATH}/dotfiles/${conf}" /root
    done

    vimplug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    curl -fLo /root/.vim/autoload/plug.vim --create-dirs "${vimplug_url}"
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

    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -t Papirus-Dark -C yaru
    "${SCRIPT_PATH}"/../scripts/tweak/themeupgrade.sh
    "${SCRIPT_PATH}"/../deployment/deploy_systools.sh

    wp_folder="/usr/share/images/desktop-base/"
    wp_url="https://raw.githubusercontent.com/choopsit/resources/main/my_debian/wallpaper/my_debian.jpg"
    rm -f "${wp_folder}my_debian.jpg"
    wget "${wp_url}" -P "${wp_folder}"
}

add_user_to() {
    local grp="$1"

    add2grp_title="Privileges elevation"
    add2grp_text="Add user '${user}' to '${grp}' group ?"
    if (whiptail --title "${add2grp_title}" --yesno "${add2grp_text}" 8 78); then
        adduser "${user}" "${grp}"
    fi
}

elevation() {
    local usr="$1"

    if ! (groups "${usr}" | grep -q sudo); then
        add_user_to sudo
    fi

    if grep -q 'virt\|cockpit' "${usefull}" && ! (groups "${usr}" | grep -q libvirt); then
        add_user_to libvirt
    fi
}

apply_perso() {
    local usr="$1"

    cfg_title="User configuration"
    cfg_text="Apply personalization to ${usr}'s profile ?"
    if (whiptail --title "${cfg_title}" --yesno "${cfg_text}" 8 78); then
        user_config "/home/${usr}"
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

end_menu() {
    reboot_title="Custom XFCE installed and configured"
    reboot_text="Reboot now and enjoy ?"
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

qtct="qt5ct"
[[ ${debian_version} == sid ]] && qtct="qt6ct"

# system part: manage packages, add few scripts to '/usr/local/bin'
#              and supply personalization for future users
clean_sources_menu
applications_adding_menu
install_packages
system_config

# users_part: privileges elevation and personalization supply
user_config_menu

# quit
end_menu
