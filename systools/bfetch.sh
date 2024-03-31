#!/usr/bin/env bash

set -e

description="Fetch system informations"
# version: 12.1
# author: Choops <choopsbd@gmail.com>

DEF="\e[0m"
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
    echo -e "  -h,--help:    Print this help"
    echo -e "  -c,--compact: Compact mode"
    echo

    exit "${errcode}"
}


[[ $1 =~ ^-(h|-help)$ ]] && usage 0
[[ $1 =~ ^-(c|-compact)$ ]] && binfo && exit
[[ $1 ]] && echo -e "${ERR} Bad argument" && usage 1


dlogo=("     ,get\$\$gg.    " 
    "   ,g\$\"     \"\$P.  " 
    "  ,\$\$\" ,o\$g. \"\$\$: " 
    "  :\$\$ ,\$\"  \"  \$\$  "
    "   \$\$ \"\$,   .\$\$\"  "
    "   \"\$\$ \"9\$\$\$P\"    "
    "    \"\$b.          "
    "      \"\$b.        "
    "         \"\"\"      "
    "     \e[30m#\e[31m#\e[32m#\e[33m#\e[34m#\e[35m#\e[36m#\e[37m#     "
)

line[0]="${GRN}${USER}${DEF}@${YLO}$(hostname -s)${DEF}"
os="$(awk -F"\"" '/^PRETTY/ {print $2}' /etc/os-release)"
line[1]="${CYN}OS${DEF}:     ${os}"

kernel="$(uname -sr)"
sepk="\t\t  "
[[ ${#kernel} -lt 7 ]] && sepk="\t\t\t  "
[[ ${#kernel} -gt 14 ]] && sepk="\t  "
nb_pkgs="$(dpkg -l | grep ^ii | wc -l)"
line[2]="${CYN}Kernel${DEF}: ${kernel}${sepk}${CYN}Packages${DEF}:  ${nb_pkgs}"

upt="$(uptime -p)"
line[3]="${CYN}Uptime${DEF}: ${upt:3}"

shell=${SHELL##*/}
if [[ ${shell} == bash ]]; then
    shell+=" ${BASH_VERSION%(*}"
else
    shell_version="$("${SHELL}" --version 2>&1)"
    # Remove unwanted info
    shell_version=${shell_version/, version}
    shell_versiob=${shell_version/xonsh\//xonsh }
    shell_version=${shell_version/options*}
    shell_version=${shell_version/\(*\)}
    shell+=" ${shell_version}"
fi
sept="\t\t  "
[[ ${#shell} -lt 7 ]] && sept="\t\t\t  "
[[ ${#shell} -gt 14 ]] && sept="\t  "
if (grep -q terminator /etc/alternatives/x-terminal-emulator); then
    term="terminator"
else
    term="$(awk -F"'" '/exec/ {print $2}' /etc/alternatives/x-terminal-emulator)"
fi
term_version="$(dpkg-query -W "${term}" | awk '{print $2}')"
term+=" ${term_version}"
line[4]="${CYN}Shell${DEF}:  ${shell}${sept}${CYN}Terminal${DEF}:  ${term}"

if [[ ${XDG_CURRENT_DESKTOP} ]]; then
    if [[ ${XDG_CURRENT_DESKTOP} == XFCE ]]; then
        de="${DESKTOP_SESSION} $(dpkg-query -W xfce4 | awk '{print $2}')"
    else
        de="${XDG_CURRENT_DESKTOP}"
    fi
elif [[ ${DESKTOP_SESSION} ]]; then
    de="${DESKTOP_SESSION}"
else
    de="N/A"
fi
wm_bin="$(update-alternatives --list x-window-manager)"
if [[ ${wm_bin} ]]; then
    wm="${wm_bin##*/}"
else
    wm="N/A"
fi
sepwm="\t\t  "
[[ ${#de} -lt 7 ]] && sepwm="\t\t\t  "
[[ ${#de} -gt 14 ]] && sepwm="\t  "
line[5]="${CYN}DE${DEF}:     ${de}${sepwm}${CYN}WM${DEF}:        ${wm}"

[[ ${wm} == xfwm4 ]] && icons="$(xfconf-query -c xsettings -p /Net/IconThemeName)"
[[ ${de} == GNOME ]] && icons="$(gsettings get org.gnome.desktop.interface icon-theme)"
sepd="\t\t  "
[[ ${#icons} -lt 7 ]] && sepd="\t\t\t  "
[[ ${#icons} -gt 14 ]] && sepd="\t  "
[[ ${wm} == xfwm4 ]] && gtk_thm="$(xfconf-query -c xfwm4 -p /general/theme)"
[[ ${de} == GNOME ]] && gtk_thm="$(gsettings get org.gnome.shell.extensions.user-theme name)"
line[6]="${CYN}Icons${DEF}:  ${icons}${sepd}${CYN}GTK-theme${DEF}: ${gtk_thm}"

cpu_file="/proc/cpuinfo"
cpu="$(awk -F '\\s*: | @' '/model name|Hardware|Processor|^cpu model|chip type|^cpu type/ { cpu=$2; if ($1 == "Hardware") exit } END { print cpu }' "$cpu_file")"
cpu="${cpu//(TM)}"
cpu="${cpu//(tm)}"
cpu="${cpu//(R)}"
cpu="${cpu//(r)}"
cpu="${cpu//CPU}"
cpu="${cpu//(\"AuthenticAMD\"*)}"
cpu="${cpu//with Radeon * Graphics}"
cpu="${cpu//, altivec supported}"
cpu="${cpu//FPU*}"
cpu="${cpu//Chip Revision*}"
cpu="${cpu//Technologies, Inc}"
cpu="${cpu//Core2/Core 2}"
cpu_speed="$(awk -F ': |\\.' '/cpu MHz|^clock/ {printf $2; exit}' "$cpu_file")"
cpu_cores="$(grep -c "^processor" "$cpu_file")"
line[7]="${CYN}CPU${DEF}:    ${cpu} (${cpu_cores}) @ ${cpu_speed}MHz"

gpu="$(lspci | grep 'display\|3D\|VGA' | sed -e 's/.*\[\(.*\)\].*/\1/')"
line[8]="${CYN}GPU${DEF}:    ${gpu}"

ram="$(free -m | awk '/^Mem:/ {print $3 "/" $2 "MB"}')"
sepm="\t\t  "
[[ ${#ram} -lt 7 ]] && sepm="\t\t\t  "
[[ ${#ram} -gt 14 ]] && sepm="\t  "
swap="$(free -m | awk '/^Swap:/ {print $3 "/" $2 "MB"}')"
line[9]="${CYN}RAM${DEF}:    ${ram}i${sepm}${CYN}Swap${DEF}: ${swap}"

colors=("${RED}" "${GRN}" "${YLO}" "${BLU}" "${PUR}" "${CYN}" "${GRY}")
rand=$[$RANDOM % ${#colors[@]}]
COL="${colors[${rand}]}"

for i in $(seq ${#dlogo[@]}); do
    idx=$(($i-1))
    echo -e "${COL}${dlogo[$idx]}${line[$idx]}"
done

echo

