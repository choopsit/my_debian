#!/usr/bin/env python3

import sys
import os
import shutil
import re

__description__ = "Graphical filesystems usage"
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
    print(f"  -h,--help: Print this help")
    print(f"  -a,--all:  Show all filesystems including tmpfs\n")
    exit(err_code)


def dim_separator(prop):
    sep = " "

    if prop == 100:
        sep = ""
    elif prop < 10:
        sep = "  "

    return sep


def color_fs(prop):
    color = "\33[32m"

    if prop >= 90:
        color = "\33[33m"
    elif prop >= 95:
        color = "\33[31m"

    return color


def dim_fsunit(vol_total):
    fs_unit = "GB"
    u_factor = (1024**3)

    if vol_total / u_factor > 1024:
        fs_unit = "TB"
        u_factor *= 1024

    return fs_unit, u_factor


def color_line(mount_point):
    fs_color = "\33[37m"

    if mount_point[1] in ["nfs", "cifs"]:
        fs_color = "\33[34m"
    elif mount_point[1].startswith("fuse"):
        fs_color = "\33[35m"
    elif mount_point[1].endswith("tmpfs"):
        fs_color = "\33[37m"

    return fs_color


def draw_fs(mount_point):
    ctxt = color_line(mount_point)

    total = shutil.disk_usage(str(mount_point[0]))[0]
    used = shutil.disk_usage(str(mount_point[0]))[1]

    used_prop = 100 * used // total

    sepg = dim_separator(used_prop)

    cfs = color_fs(used_prop)
    cn = "\33[37m"

    total_lg = 10
    used_lg = used_prop * total_lg // 100
    used_gr = used_lg * f"#"
    free_gr = (total_lg - used_lg) * "-"

    unit, factor = dim_fsunit(total)

    total_u = total / factor
    used_u = used / factor
    free_u = total_u - used_u

    lensepdv = 10 - len(mount_point[2])
    sepdv = " " * lensepdv

    mydev = mount_point[2].split("/")[-1]
    tline = f"{CYN}{mydev}{DEF}{sepdv}[{ctxt}{mount_point[1]}{DEF}] "
    # tline = f"{CYN}{mount_point[2]}{DEF}{sepdv}[{ctxt}{mount_point[1]}{DEF}] "

    lensepfs = 5 - len(mount_point[1])
    sepfs = " " * lensepfs

    tline += f"{sepfs}on {ctxt}{mount_point[0]}{DEF}"

    repart = f"{used_u:.1f}{DEF}/{ctxt}{total_u:.1f}{DEF}{unit}"

    lensepsp = 26 - len(repart)
    sepsp = " " * lensepsp

    gline = f"  [{cfs}{used_gr}{cn}{free_gr}{DEF}]{sepg}{cfs}{used_prop}{DEF}%"
    gline += f" {sepsp}{ctxt}{repart}{DEF}"

    freesp= f"{free_u:.1f}{DEF}{unit}"

    lenfsep = 12 - len(freesp)
    fsep = " " * lenfsep

    gline += f" -{fsep}{ctxt}{freesp} free{DEF}"

    lensep = 16 - len(mount_point[0])
    sep = " " * lensep

    print(f"{tline}{sep}{gline}")


def fs_info(fs_regex):
    print(f"{CYN}Filesystems{DEF}:")

    with open("/proc/mounts", "r") as f:
        mounts = [(line.split()[1].replace('\\040', ' '), line.split()[2], line.split()[0])
                for line in f.readlines()]

        for mnt_point in mounts:
            if re.match(fs_regex, mnt_point[1]):
                draw_fs(mnt_point)

    print()


if __name__ == "__main__":
    my_fs_regex = 'ext|btrfs|lvm|xfs|zfs|ntfs|vfat|fuseblk|nfs$|nfs4|cifs'

    if any(arg in sys.argv for arg in ["-h","--help"]):
        usage()
    elif len(sys.argv) == 2 and sys.argv[1] in ["-a","--all"]:
        my_fs_regex += '|.*tmpfs'
    elif len(sys.argv) > 1:
        print(f"{ERR} Bad argument\n")
        usage(1)

    fs_info(my_fs_regex)
