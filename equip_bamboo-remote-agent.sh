#!/bin/sh

# Equip Atlassian Bamboo Remote Agent on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: Atlassian Bamboo Remote Agent
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
    echo >&2 "! Failed installation, entering cleanup."
    rm -f /atlassian-bamboo-agent-installer-${BAMBOO_AGENT_VERSION}.jar 2>/dev/null
    exit 1
}

trap 'cleanup' ERR

if [ ! -d "/usr/lib/jvm/" ]; then
	echo "There is no installation of Java JDK in /usr/lib/jvm."
    echo "Install a JDK (1.7 or above) before running this script."
	exit 1
fi

if [[ -z ${1} ]]; then
    echo >&2 "Bamboo Agent version not provided. The version is required to complete the install."
    exit 2
fi

BAMBOO_AGENT_VERSION=${1}

if [[ -z ${2} ]]; then
    echo >&2 "Bamboo server host name was not provided. The server url is required to complete the install."
    exit 2
fi

BAMBOO_SERVER_HOSTNAME=${2}

echo "Installing Bamboo Agent version ${BAMBOO_AGENT_VERSION}."

BAMBOO_AGENT_JAR='atlassian-bamboo-agent-installer-'${BAMBOO_AGENT_VERSION}'.jar'
BAMBOO_AGENT_PREFIX='/root'

yum install -y -q curl

curl --silent -L http://${BAMBOO_SERVER_HOSTNAME}/agentServer/agentInstaller/${BAMBOO_AGENT_JAR} > ${BAMBOO_AGENT_PREFIX}/${BAMBOO_AGENT_JAR}

if [[ -z $JAVA_HOME ]]; then
    export JAVA_HOME=$(update-alternatives --display java | grep "\`best'" | egrep -o '/.+' | sed 's/bin\/java.*//')
fi

java -jar atlassian-bamboo-agent-installer-5.9.7.jar http://${BAMBOO_SERVER_HOSTNAME}/agentServer/
