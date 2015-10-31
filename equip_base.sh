#!/bin/sh

# Equip base packages to prepare CentOS for other "equip-centos" scripts
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: java8_64
# To run, see https://github.com/brian-dlee/centos-equip

sudo yum install -y make automake gcc gcc-c++ kernel-devel
sudo yum install -y rsync telnet screen wget
sudo yum install -y strace tcpdump
sudo yum install -y openssl-devel zlib-devel libcurl-devel libxslt-devel

sudo yum install -y git
