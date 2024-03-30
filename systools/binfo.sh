#!/usr/bin/env bash

DEF="\e[0m"
RED="\e[31m"
GRN="\e[32m"
YLO="\e[33m"
BLU="\e[34m"
PUR="\e[35m"
CYN="\e[36m"
GRY="\e[37m"

palette="\e[30m#\e[31m#\e[32m#\e[33m#\e[34m#\e[35m#\e[36m#\e[37m#"

colors=("${RED}" "${GRN}" "${YLO}" "${BLU}" "${PUR}" "${CYN}" "${GRY}")
rand=$[$RANDOM % ${#colors[@]}]
col_deb="${colors[${rand}]}"

col_usr="${GRN}"
[[ $USER = root ]] && col_usr="${RED}"

my_os="$(awk -F\" '/^PRETTY/ {print $2}' /etc/os-release)"

my_shell="$(basename "${SHELL}")"
if [[ ${my_shell} == bash ]]; then
    my_shell+=" ${BASH_VERSION%(*}"
else
    shell_version="$("${SHELL}" --version 2>&1)"
    # Remove unwanted info
    shell_version=${shell_version/, version}
    shell_versiob=${shell_version/xonsh\//xonsh }
    Shell_version=${shell_version/options*}
    shell_version=${shell_version/\(*\)}
    my_shell+=" ${shell_version}"
fi

my_ram="$(free -m | awk '/^Mem:/ {print $3 "/" $2 "MB"}')"
my_swap="$(free -m | awk '/^Swap:/ {print $3 "/" $2 "MB"}')"

echo -e "${col_deb}   .a#\$\$#a.   ${col_usr}${USER}${DEF}@${YLO}$(hostname -s)${DEF}"
echo -e "${col_deb}  d#\"    \"#b  ${CYN}OS${DEF}: ${my_os}"
echo -e "${col_deb}  ##  d\"  ##  ${CYN}kernel${DEF}: $(uname -r)"
echo -e "${col_deb}  \"#. \"#\$#\"   ${CYN}shell${DEF}: ${my_shell}"
echo -e "${col_deb}   \"#.        ${CYN}packages${DEF}: $(dpkg -l | grep '^ii' | wc -l)"
echo -e "${col_deb}     \"+.      ${CYN}uptime${DEF}: $(uptime -p | sed 's/up //')"
echo -e "   ${palette}   ${CYN}RAM${DEF}: ${my_ram}\t${CYN}swap${DEF}: ${my_swap}\n"
