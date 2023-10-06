#!/usr/bin/env python3

import sys
import re
import os
import subprocess
import socket
import fcntl
import struct

__description__ = "Show network informations"
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
    print(f"  -h,--help: Print this help\n")
    exit(err_code)


def get_host_info():
    my_hostname = socket.gethostname()

    my_fqdn = socket.getfqdn()

    if my_fqdn != my_hostname:
        my_hostname = my_fqdn

    print(f"{CYN}Hostname/FQDN{DEF}: {YLO}{my_hostname}")


def get_mtu(ifname):
    return open(f"/sys/class/net/{ifname}/mtu").readline().rstrip("\n")


def get_mac(ifname):
    return open(f"/sys/class/net/{ifname}/address").readline().rstrip("\n")


def get_ip(ifname):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sockfd = sock.fileno()
    SIOCGIFADDR = 0x8915

    ifreq = struct.pack('16sH14s', ifname.encode('utf-8'), socket.AF_INET,
                        b'\x00'*14)

    try:
        res = fcntl.ioctl(sockfd, SIOCGIFADDR, ifreq)
    except:
        return None

    ip = struct.unpack('16sH2x4s8x', res)[2]

    return socket.inet_ntoa(ip)


def get_gw():
    get_gw_cmd = "ip r | grep default | awk '{print $3}'"

    return os.popen(get_gw_cmd).read().rstrip("\n")


def get_dns():
    get_dns_cmd = "dig | awk -F'(' '/SERVER:/{print $2}' | sed 's/.$//'"

    return os.popen(get_dns_cmd).read().rstrip(")\n")


def list_ifaces():
    if_list = os.listdir('/sys/class/net/')

    for iface in if_list:
        if not re.match('^(lo|vif.*|virbr.*-.*|vnet.*)$', iface):
            print(f"{CYN}Interface{DEF}: {iface}")
            mtu = get_mtu(iface)
            print(f"  - {CYN}MTU{DEF}:         {mtu}")
            macaddr = get_mac(iface)
            print(f"  - {CYN}MAC address{DEF}: {macaddr}")
            ipaddr = get_ip(iface)
            print(f"  - {CYN}IP address{DEF}:  {ipaddr}")

    gw = get_gw()
    print(f"{CYN}Gateway{DEF}:         {gw}")

    nameserver = get_dns()
    print(f"{CYN}DNS nameserver{DEF}:  {nameserver}")
    print()


if __name__ == "__main__":
    if any(arg in sys.argv for arg in ["-h","--help"]):
        usage()
    elif len(sys.argv) > 1:
        print(f"{ERR} Bad argument")
        usage(1)

    get_host_info()
    list_ifaces()
