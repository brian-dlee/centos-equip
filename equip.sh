#!/bin/sh

# Equip script wrapper
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Usage:
#   wget --no-check-certificate https://github.com/brian-dlee/centos-equip/raw/master/equip.sh && bash equip.sh [component]

if [[ ! $(which wget) ]]; then
    sudo yum install -y wget
fi

GITHUB_URL="https://github.com/brian-dlee/ubuntu-equip/raw/master/"
WGET_CMD=$(which wget)
WGET_OPTS="--no-check-certificate"

function runInstallScript {
    echo "Running installation for '$1'"

    $WGET_CMD $WGET_OPTS $GITHUB_URL/equip_$1.sh && bash equip_$1.sh

    result=$?

    if [[ -e equip_$1.sh ]]; then
        rm -f equip_$1.sh
    fi

    if [[ $result != 0 ]]; then
        echo >&2 "Failed install for '$1'";
        return 1
    else
        echo "Successfully ran installation for '$1'"
        return 0
    fi
}

components=('base')

while [[ ${#[@]} > 1 ]]; do
    component=$(shift)

    case $component in
        'base' );;
        'java8_64' )
            components+=("java8_64");;
        '*' )
            echo >&2 "Unknown installation request: '$component'"
            exit 1;;
    esac
done

sudo yum update -y

for component in ${components[@]}; do
    runInstallScript $component

    if [[ $? != 0 ]]; then
        break;
    fi
done

rm -f equip.sh
