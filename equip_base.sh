#!/bin/sh

# Equip base packages to prepare CentOS for other "equip-centos" scripts
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: java8_64
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
    echo >&2 "! Failed installation, entering cleanup."
    exit 1
}

trap 'cleanup' ERR

echo "Installing CentOS prerequisite packages."

yum install -y -q make automake gcc gcc-c++ kernel-devel
yum install -y -q rsync telnet screen wget
yum install -y -q strace tcpdump
yum install -y -q openssl-devel zlib-devel libcurl-devel libxslt-devel

yum install -y -q git
