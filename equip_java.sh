#!/bin/sh

# Equip 64-bit Java on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: java
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
	echo >&2 "! Failed installation, entering cleanup."
	rm -f /${JAVA_ARCHIVE} 2>/dev/null
    exit 1
}

trap 'cleanup' ERR

JAVA_MAJOR_VERSION='7'
JAVA_MINOR_VERSION='80'
JAVA_MTN_KEY='b15'

case ${1} in
	''|7);;
	8)
		JAVA_MAJOR_VERSION='8'
		JAVA_MINOR_VERSION='66'
		JAVA_MTN_KEY='b17'
		;;
	*)
		echo >&2 "Cannot install the desired version of java (${1})"
		exit 2
esac

echo "Running installer Oracle Java Version ${JAVA_MAJOR_VERSION}"

JAVA_PACKAGE="jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_MINOR_VERSION}"
JAVA_INSTALL_ENTRY=$(update-alternatives --display java | grep 'priority' | grep "${JAVA_PACKAGE}")

if [[ ${JAVA_INSTALL_ENTRY} ]]; then
	echo "Java ${JAVA_MAJOR_VERSION} is already installed."
	echo "- ${JAVA_INSTALL_ENTRY}"
	exit 0
fi

yum install -y -q curl

JAVA_RPM="jdk-${JAVA_MAJOR_VERSION}u${JAVA_MINOR_VERSION}-linux-x64.rpm"
JAVA_DL_DIR='/root'
JAVA_DL_DEST="${JAVA_DL_DIR}/${JAVA_RPM}"

JAVA_DL_URL="http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_MINOR_VERSION}-${JAVA_MTN_KEY}/${JAVA_RPM}"

echo "Downloading Java JDK RPM - ${JAVA_DL_URL}"
curl -L --cookie "oraclelicense=accept-securebackup-cookie" ${JAVA_DL_URL} -o /${JAVA_DL_DEST}

yum -y -q localinstall ${JAVA_DL_DEST}

rm -f ${JAVA_DL_DEST}

export JAVA_HOME=$(update-alternatives --display java | grep "\`best'" | egrep -o '/.+' | sed 's/bin\/java.*//')
cat >/etc/profile.d/oracle-java-${JAVA_MAJOR_VERSION}.sh <<< "export JAVA_HOME=${JAVA_HOME}"

echo "Successfully installed Oracle Java Version ${JAVA_MAJOR_VERSION}"
