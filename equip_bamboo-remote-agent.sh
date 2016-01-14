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
BAMBOO_AGENT_JAR_DESTINATION=${BAMBOO_AGENT_PREFIX}/${BAMBOO_AGENT_JAR}

yum install -y -q curl

curl -L http://${BAMBOO_SERVER_HOSTNAME}/agentServer/agentInstaller/${BAMBOO_AGENT_JAR} > ${BAMBOO_AGENT_JAR_DESTINATION}

if [[ -z $JAVA_HOME ]]; then
    export JAVA_HOME=$(update-alternatives --display java | grep "\`best'" | egrep -o '/.+' | sed 's/bin\/java.*//')
fi

cat >/etc/profile.d/bamboo-remote-agent.sh <<< "export JAVA_HOME=${JAVA_HOME}"

java -jar ${BAMBOO_AGENT_JAR_DESTINATION} http://${BAMBOO_SERVER_HOSTNAME}/agentServer/
