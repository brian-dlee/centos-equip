#!/bin/sh

# Equip script wrapper
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# To run, see https://github.com/brian-dlee/centos-equip

GITHUB_ROOT="https://github.com/brian-dlee/centos-equip"
GITHUB_URL="$GITHUB_ROOT/raw/master/"
WGET_CMD=$(which wget)
WGET_OPTS="--no-check-certificate"

if [[ $? != 0 ]]; then
    sudo yum install -y wget

    WGET_CMD=$(which wget)

    if [[ $? != 0 ]]; then
        echo >&2 "The package 'wget' could not be installed. Install 'wget' and rerun: `yum install -y wget`."
        exit 1
    fi
fi

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

if [[ $# == 0 ]]; then
    echo "No components provided."
    echo "For usage, see $GITHUB_ROOT."
    exit 1
fi

while [[ $# > 0 ]]; do
    case $1 in
        'base' );;
        'java8_64' )
            components+=("java8_64");;
        '*' )
            echo >&2 "Unknown installation request: '$1'"
            exit 2;;
    esac
    shift
done

sudo yum update -y

for component in ${components[@]}; do
    runInstallScript $component

    if [[ $? != 0 ]]; then
        break;
    fi
done
