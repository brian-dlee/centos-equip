#!/bin/sh

# Equip script wrapper
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# To run, see https://github.com/brian-dlee/centos-equip

GITHUB_ROOT="https://github.com/brian-dlee/centos-equip"
GITHUB_URL="${GITHUB_ROOT}/raw/master"
WGET_CMD=$(which wget 2>/dev/null)
WGET_OPTS="--quiet --no-check-certificate"

export EQUIP_SELINUX_ENABLED=0
export EQUIP_FIREWALL_ENABLED=0

if [[ $(which sestatus 2>/dev/null) && -z $(sestatus | egrep 'SELinux status:\s+disabled') ]]; then
    export EQUIP_SELINUX_ENABLED=1
fi



# Make sure only root can run our script
if [[ ${EUID} -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ -z ${WGET_CMD} ]]; then
    yum install -y -q wget

    WGET_CMD=$(which wget 2>/dev/null)

    if [[ ${?} != 0 ]]; then
        echo >&2 "The package 'wget' could not be installed. Install 'wget' and rerun: `yum install -y wget`."
        exit 1
    fi
fi

function collapseComponents {
    i=0
    list=()
    element=shift

    while [[ ${element} ]]; do
        if [[ $(echo ${components[@]} | egrep -v "${element} ") ]]; then
            list+=("${element}")
        fi
        element=shift
    done

    echo ${list[@]}
}

function runInstallScript {
    echo "Running installation for '${1}'"

    component=${1}
    tag=""

    if [[ $(echo ${component} | grep ':') ]]; then
        parts=($(echo ${component} | sed -r 's/:/ /'))
        component=${parts[0]}
        tag=${parts[1]}
    fi

    ${WGET_CMD} ${WGET_OPTS} ${GITHUB_URL}/equip_${component}.sh && bash equip_${component}.sh ${tag}

    result=${?}

    if [[ -e equip_${component}.sh ]]; then
        rm -f equip_${component}.sh
    fi

    if [[ ${result} != 0 ]]; then
        echo >&2 "Failed install for '${1}'";
        return 1
    else
        echo "Successfully ran installation for '${1}'"
        return 0
    fi
}

components=('base')

if [[ ${#} == 0 ]]; then
    echo "No components provided."
    echo "For usage, see ${GITHUB_ROOT}."
    exit 1
fi

while [[ ${#} > 0 ]]; do
    case ${1} in
        'base');;
        'java7')
            components+=("java:7");;
        'java8')
            components+=("java:8");;
        'maven')
            components+=("java:7" "maven");;
        'tomcat7')
            components+=("java:7" "tomcat:7");;
        'tomcat8')
            components+=("java:7" "tomcat:8");;
        *)
            echo >&2 "Unknown installation request: '$1'"
            exit 2;;
    esac
    shift
done

components=($(collapseComponents ${#components[@]} ${components[@]}))

yum update -y -q

for component in ${components[@]}; do
    runInstallScript ${component}

    if [[ ${?} != 0 ]]; then
        break;
    fi
done
