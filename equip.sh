#!/bin/sh

# Equip script wrapper
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# To run, see https://github.com/brian-dlee/centos-equip

EQUIP_LOCATION=$(cd $(dirname $0) && pwd)
EQUIP_OPT_FORCE_UPDATE=0
EQUIP_OPT_SKIP_BASE=0

GITHUB_ROOT="https://github.com/brian-dlee/centos-equip"
GITHUB_URL="${GITHUB_ROOT}/raw/master"

yum install -y -q which 2>/dev/null

if [[ ${?} != 0 ]]; then
    echo >&2 "The package 'which' could not be installed. Install 'which' and rerun."
    exit 1
fi

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
    yum install -y -q wget 2>/dev/null

    WGET_CMD=$(which wget 2>/dev/null)

    if [[ ${?} != 0 ]]; then
        echo >&2 "The package 'wget' could not be installed. Install 'wget' and rerun."
        exit 1
    fi
fi

function collapseComponents {
    list=($1)
    shift

    while [[ ! -z ${1} ]]; do
        if [[ $(echo ${list[@]} | grep -v "${1}") ]]; then
            list+=("${1}")
        fi
        shift
    done

    echo ${list[@]}
}

function runInstallScript {
    if [[ ${1} == 'base' && ${EQUIP_OPT_SKIP_BASE} == 1 ]]; then
        return 0
    fi

    echo "Running installation for '${1}'"

    component=${1}
    args=""

    if [[ $(echo ${component} | grep ':') ]]; then
        parts=($(echo ${component} | sed -r 's/:/ /g'))
        component=${parts[0]}
        args=${parts[@]:1}
    fi

    script_destination="${EQUIP_LOCATION}/equip_${component}.sh"
    found_component_script=0

    if [[ ! -e ${script_destination} || ${EQUIP_OPT_FORCE_UPDATE} == 1 ]]; then
        if [[ -e ${script_destination} ]]; then
            found_component_script=1
        fi

        ${WGET_CMD} -P ${EQUIP_LOCATION} ${GITHUB_URL}/equip_${component}.sh
    else
        echo "Found existing component script. Executing ${script_destination}."
        found_component_script=1
    fi

    bash ${script_destination} ${args[@]}

    result=${?}

    if [[ -e equip_${component}.sh && ! ${found_component_script} ]]; then
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

function showUsage {
    echo "Usage: equip.sh [OPTIONS] [COMPONENTS]"
    echo "  -d  --disable-base:     Prevent execution of equip_base.sh (by default this always runs)"
    echo "  -u  --force-update:     The default is to use local component installation scripts if possible, this prevents it"
    echo "  -h  --help:             Shows this usage dialog"
}

components=('base')

if [[ ${#} == 0 ]]; then
    echo "No components provided."
    echo "For usage, see ${GITHUB_ROOT}."
    exit 1
fi

while [[ ${#} > 0 ]]; do
    case ${1} in
        base);;
        bamboo-remote-agent:*)
            components+=("java:8 ${1}")
            ;;
        java|java:7)
            components+=("java:7");;
        java:8)
            components+=("java:8");;
        maven|maven:3)
            components+=("java:7" "maven:3");;
        tomcat|tomcat:7)
            components+=("java:7" "tomcat:7");;
        tomcat:8)
            components+=("java:7" "tomcat:8");;

        --disable-base|-d)
            EQUIP_OPT_SKIP_BASE=1;;
        --force-update|-u)
            EQUIP_OPT_FORCE_UPDATE=1;;
        --help|-h)
            showUsage
            exit 0
            ;;
        *)
            echo >&2 "Unknown installation request: '${1}'"
            exit 2
            ;;
    esac
    shift
done

components=($(collapseComponents ${components[@]}))

yum update -y -q

for component in ${components[@]}; do
    runInstallScript ${component}

    if [[ ${?} != 0 ]]; then
        exit ${?}
    fi
done
