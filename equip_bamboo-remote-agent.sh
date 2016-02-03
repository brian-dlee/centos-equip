#!/bin/sh

# Equip Atlassian Bamboo Remote Agent on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: Atlassian Bamboo Remote Agent
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
    echo >&2 "! Failed installation, entering cleanup."
    rm -f ${BAMBOO_AGENT_JAR_DESTINATION} 2>/dev/null
    exit 1
}

trap 'cleanup' ERR

if [[ -z ${1} ]]; then
    echo >&2 "Bamboo Agent version not provided. The version is required to complete the install."
    exit 2
fi

BAMBOO_AGENT_VERSION=${1}

if [[ -z ${BAMBOO_SERVER} && -z ${2} ]]; then
    echo >&2 "Bamboo server host name was not provided. The server url is required to complete the install."
    exit 2
fi

if [[ -z ${BAMBOO_SERVER} ]]; then
    BAMBOO_SERVER=${2}
fi

if [[ ! ${BAMBOO_SERVER} =~ :[0-9]+$ ]]; then
    if [[ -n ${3} ]]; then
        BAMBOO_SERVER+="${3}"
    else
        BAMBOO_SERVER+=":8085"
    fi
fi

INSTALL_PREFIX='/root'

if [[ -z ${BAMBOO_HOME} ]]; then
    BAMBOO_HOME="${INSTALL_PREFIX}/bamboo-agent-home"
fi

echo "Installing Bamboo Agent version ${BAMBOO_AGENT_VERSION}."

if [[ -e ${BAMBOO_HOME} && -e "${BAMBOO_HOME}/bin/bamboo-agent.sh" ]]; then
    echo "Bamboo Remote Agent is already installed at ${BAMBOO_HOME}."
    echo "If you'd like to reinstall, delete ${BAMBOO_HOME} and rerun this script."
    exit 0
fi

BAMBOO_AGENT_JAR='atlassian-bamboo-agent-installer-'${BAMBOO_AGENT_VERSION}'.jar'
BAMBOO_AGENT_JAR_DESTINATION=${INSTALL_PREFIX}/${BAMBOO_AGENT_JAR}

yum install -y -q curl

echo "Downloading the Bamboo Remote Agent JAR file"
echo " -  http://${BAMBOO_SERVER}/agentServer/agentInstaller/${BAMBOO_AGENT_JAR}"

curl -L http://${BAMBOO_SERVER}/agentServer/agentInstaller/${BAMBOO_AGENT_JAR} > ${BAMBOO_AGENT_JAR_DESTINATION}

java -jar ${BAMBOO_AGENT_JAR_DESTINATION} http://${BAMBOO_SERVER}/agentServer/ install

if [[ -z $JAVA_HOME ]]; then
    export JAVA_HOME=/usr/java/default
fi

cat >/etc/profile.d/bamboo-remote-agent.sh < /dev/null
cat >/etc/profile.d/bamboo-remote-agent.sh <<< "export JAVA_HOME=${JAVA_HOME}"
cat >/etc/profile.d/bamboo-remote-agent.sh <<< "export BAMBOO_SERVER=${BAMBOO_SERVER}"
cat >/etc/profile.d/bamboo-remote-agent.sh <<< "export BAMBOO_HOME=${BAMBOO_HOME}"
