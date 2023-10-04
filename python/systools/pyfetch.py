#!/usr/bin/env python3

import sys
import apt
import os
import shutil
import getpass
import socket
import platform
import subprocess
import datetime
import pathlib

__description__ = "Fetch system informations"
__author__ = "Choops <choopsbd@gmail.com>"
__version__ = "12.0"

DEF = "\33[0m"
RED = "\33[31m"
GRN = "\33[32m"
YLO = "\33[33m"
CYN = "\33[36m"

ERR = f"{RED}ERR{DEF}:"
OK = f"{GRN}OK{DEF}:"
WRN = f"{YLO}WRN{DEF}:"
NFO = f"{CYN}NFO{DEF}"


def usage(err_code=0):
    my_script = os.path.basename(__file__)
    print(f"{CYN}{__description__}\nUsage{DEF}:")
    print(f"  {my_script} [OPTION]")
    print(f"{CYN}Options{DEF}:")
    print(f"  -h,--help:         Print this help")
    print(f"  -d,--default-logo: Use default logo")
    print()
    exit(err_code)


def python_logo():
    dlogo = []
    cl = ["\33[34m", "\33[33m"]
    dlogo.append(f"{cl[0]}      .####.      ")
    dlogo.append(f"{cl[0]}      #.####      ")
    dlogo.append(f"{cl[0]}  .######### {cl[1]}###. ")
    dlogo.append(f"{cl[0]}  ########## {cl[1]}#### ")
    dlogo.append(f"{cl[0]}  #### {cl[1]}########## ")
    dlogo.append(f"{cl[0]}  `### {cl[1]}#########` ")
    dlogo.append(f"{cl[1]}       ####`#     ")
    dlogo.append(f"{cl[1]}       `####`     ")
    dlogo.append("                  ")

    return dlogo


def distro_logo(dist):
    dlogo = []
    if dist == "debian":
        cl = ["\33[31m"]
        dlogo.append(f"{cl[0]}     ,get$$gg.    ")
        dlogo.append(f"{cl[0]}   ,g$\"     \"$P.  ")
        dlogo.append(f"{cl[0]}  ,$$\" ,o$g. \"$$: ")
        dlogo.append(f"{cl[0]}  :$$ ,$\"  \"  $$  ")
        dlogo.append(f"{cl[0]}   $$ \"$,   .$$\"  ")
        dlogo.append(f"{cl[0]}   \"$$ \"9$$$P\"    ")
        dlogo.append(f"{cl[0]}    \"$b.          ")
        dlogo.append(f"{cl[0]}      \"$b.        ")
        dlogo.append(f"{cl[0]}         \"\"\"      ")
    elif dist == "raspbian":
        cl = ["\33[32m", "\33[31m"]
        dlogo.append(f"{cl[0]} o.     .oo@$$$$$°")
        dlogo.append(f"{cl[0]} $$$o..o$$$$$$$*' ")
        dlogo.append(f"{cl[0]} $${cl[1]}.o@@o.{cl[0]}$$$*'    ")
        dlogo.append(f"{cl[1]} . $$$$$$ .o@o.   ")
        dlogo.append(f"{cl[1]} $ '*$$*' $$$$$   ")
        dlogo.append(f"{cl[1]} ' .o@@o. '*$*'.$ ")
        dlogo.append(f"{cl[1]} . $$$$$$ .o@o.'$ ")
        dlogo.append(f"{cl[1]} $ '*$$*' $$$$$   ")
        dlogo.append(f"{cl[1]} ' .o@@o. '*$*'   ")
    else:
        dlogo = python_logo()

    return dlogo


def draw_logo(default):
    cpalette = ["\33[30m", "\33[31m", "\33[32m", "\33[33m", "\33[34m",
                "\33[35m", "\33[36m", "\33[37m"]

    palette = ""
    for cpal in cpalette:
        palette += f"{cpal}#{DEF}"

    logo = []

    dist = ""
    with open("/etc/os-release", "r") as osfile:
        for line in osfile:
            if line.startswith("ID="):
                dist = line.split("=")[1].rstrip("\n").lower()

    if dist and default is False:
        logo = distro_logo(dist)
    else:
        logo = python_logo()

    logo.append(f"     {palette}     ")

    return logo, dist


def get_host():
    cu = "\33[32m"
    ch = "\33[33m"
    my_user = getpass.getuser()
    my_hostname = socket.gethostname()

    return f"{cu}{my_user}{DEF}@{ch}{my_hostname}{DEF}"


def get_os():
    with open("/etc/os-release", "r") as os_file:
        for line in os_file:
            if line.startswith("PRETTY"):
                os_name = line.split("=")[1].rstrip("\n").replace("\"", "")

    os_name += " "+platform.machine()

    return f"{CYN}OS{DEF}:     {os_name}"


def get_kernel():
    kernel = platform.release()

    sep = ""

    if len(kernel) < 12:
        sep = "\t"

    return f"{CYN}Kernel{DEF}: {kernel}{sep}"


def get_packages(dist):
    pkg_count = "N/A"

    dist_ok = ["debian", "raspbian", "ubuntu"]

    if dist in dist_ok:
        list_cmd = ['dpkg', '-l']
        count_cmd = ['grep', '-c', '^i']
        pkg_list = subprocess.Popen(list_cmd, stdout=subprocess.PIPE)
        pkg_count = subprocess.check_output(count_cmd, stdin=pkg_list.stdout,
                universal_newlines=True).rstrip("\n")

    return f"{CYN}Packages{DEF}:  {pkg_count}"


def get_uptime():
    with open('/proc/uptime', 'r') as f:
        uptime_seconds = int(float(f.readline().split()[0]))
        uptime_string = datetime.timedelta(seconds=uptime_seconds)

    return f"{CYN}Uptime{DEF}: {uptime_string}"


def get_shell():
    shell = os.path.basename(os.environ['SHELL'])
    shell_vf = str(subprocess.check_output(['bash', '--version'])).split()[3]
    shell_v = shell_vf.split("(")[0]

    return f"{CYN}Shell{DEF}:  {shell} {shell_v}"


def get_term():
    term = "N/A"

    get_term_cmd = "cat /etc/alternatives/x-terminal-emulator | grep exec"

    term_bin = os.popen(get_term_cmd).read().rstrip()

    if term_bin:
        term_cmd = term_bin.split("'")[1]
    else:
        term_cmd = "x-terminal-emulator"

    term_vers_cmd = f"{term_cmd} --version 2>/dev/null"
    term = os.popen(term_vers_cmd).read().rstrip()
    if "\n" in term:
        term = term.partition('\n')[0]

    return f"{CYN}Terminal{DEF}:  {term}"


def get_de():
    try:
        de = os.environ['XDG_CURRENT_DESKTOP']
    except KeyError:
        try:
            de = os.environ['DESKTOP_SESSION']
        except KeyError:
            de = "N/A"

    if de == "XFCE":
        get_xfce_version = "xfce4-about -V 2>/dev/null"
        for line in os.popen(get_xfce_version).read().split("\n"):
            if line.startswith("xfce4-about"):
                de = line.split("(")[1][:-1]

    wm_chk_cmd = ['update-alternatives', '--list', 'x-window-manager']

    try:
        get_wm = subprocess.check_output(wm_chk_cmd, universal_newlines=True)
        wm = get_wm.split("/")[-1].rstrip("\n")
    except subprocess.CalledProcessError:
        wm = "N/A"

    sep = "\t\t"

    if len(de) < 5:
        sep += "\t"
    elif len(de) > 12:
        sep = "\t"

    return f"{CYN}DE{DEF}:     {de}{sep}{CYN}WM{DEF}:\t   {wm}", de, wm


def get_perso(de, wm):
    gtk_th = ""
    icon_th = ""
    home = str(pathlib.Path.home())

    if de == "XFCE" or wm == "xfwm4":
        conf = f"{home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"

        with open(conf, "r") as f:
            for line in f:
                if "\"ThemeName" in line:
                    gtk_th = line.split('="')[-1].split('"')[0]

                if "IconThemeName" in line:
                    icon_th = line.split('="')[-1].split('"')[0]
    elif wm == "awesome":
        conf = f"{home}/.gtkrc-2.0"

        if os.path.isfile(conf):
            with open(conf, "r") as f:
                for line in f:
                    if line.startswith("gtk-theme-name"):
                        gtk_th = line.split('="')[-1].split('"')[0]

                    if line.startswith("gtk-icon-theme-name"):
                        icon_th = line.split('="')[-1].split('"')[0]

    sep = "\t\t"

    if len(icon_th) < 5:
        sep += "\t"
    elif len(icon_th) > 12:
        sep = "\t"

    return f"{CYN}Icons{DEF}:  {icon_th}{sep}{CYN}GTK-theme{DEF}: {gtk_th}"


def get_cpu():
    thread_count = 0
    with open("/proc/cpuinfo", "r") as f:
        for line in f:
            if line.startswith("model name"):
                thread_count += 1
                cpu = line.split(': ')[1].rstrip("\n")

    return f"{CYN}CPU{DEF}:    {cpu} ({thread_count} threads)"


def get_gpu():
    pci_list_cmd = ['lspci']
    filter_cmd = ['grep', 'VGA']
    pci_info = subprocess.Popen(pci_list_cmd, stdout=subprocess.PIPE)
    gpu_info = subprocess.check_output(filter_cmd, stdin=pci_info.stdout,
            universal_newlines=True).rstrip("\n")
    gpu = gpu_info.split(": ")[1]

    return f"{CYN}GPU{DEF}:    {gpu}"


def get_mem():
    with open("/proc/meminfo", "r") as f:
        for line in f:
            if line.startswith("MemTotal:"):
                mem_total = int(line.split(None, 2)[1]) // 1024

            if line.startswith("MemAvailable:"):
                mem_used = mem_total - int(line.split(None, 2)[1]) // 1024

            if line.startswith("SwapTotal:"):
                swap_total = int(line.split(None, 2)[1]) // 1024

            if line.startswith("SwapFree:"):
                swap_used = swap_total - int(line.split(None, 2)[1]) // 1024

    mem_repart = f"{mem_used}/{mem_total}"
    swap_repart = f"{swap_used}/{swap_total}"
    msep = "\t"

    if len(mem_repart) < 10:
        msep += "\t"

    ret = f"{CYN}RAM{DEF}:    {mem_repart}MB {msep}"
    ret += f"{CYN}Swap{DEF}:      {swap_repart}MB"

    return ret


def pick_infos(logo, dist):
    info_list = []
    info_list.append(get_host())
    info_list.append(get_os())
    info_list.append(f"{get_kernel()}\t{get_packages(dist)}")
    info_list.append(get_uptime())
    info_list.append(f"{get_shell()}\t\t{get_term()}")

    deinfo, de, wm = get_de()

    info_list.append(deinfo)
    info_list.append(get_perso(de, wm))
    info_list.append(get_cpu())

    if dist != 'raspbian':
        info_list.append(get_gpu())

    info_list.append(get_mem())

    while len(info_list) < len(logo):
        info_list.append("")

    return info_list


def show_infos(logo, info):
    for i in range(len(logo)):
        print(logo[i], info[i])

    print()


if __name__ == "__main__":
    default_logo = False

    if any(arg in sys.argv for arg in ["-h","--help"]):
        usage()
    elif len(sys.argv) == 2 and sys.argv[1] in ["-d","--default-logo"]:
        default_logo = True
    elif len(sys.argv) > 1:
        print(f"{ERR} Bad argument")
        usage(1)

    my_logo, my_dist = draw_logo(default_logo)
    my_info = pick_infos(my_logo, my_dist)

    show_infos(my_logo, my_info)
