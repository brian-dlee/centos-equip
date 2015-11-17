#!/bin/sh

# Equip 64-bit Java on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: java
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
	rm -f /${JAVA_ARCHIVE} 2>/dev/null
    exit 1
}

JAVA_MAJOR_VERSION='7'
JAVA_MINOR_VERSION='65'

case ${1} in
	'8')
		JAVA_MAJOR_VERSION='8'
		JAVA_MINOR_VERSION='66'
		;;
	'*')
		echo >&2 "Cannot install the desired version of java (${1})"
		exit 2
esac

JAVA_INSTALL_PREFIX="/usr/lib/jvm"
JAVA_INSTALL="${JAVA_INSTALL_PREFIX}/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_MINOR_VERSION}"
JAVA_ARCHIVE=jdk-${JAVA_MAJOR_VERSION}-linux-x64.tar.gz

trap 'cleanup' ERR

if [ -d ${JAVA_INSTALL_PREFIX} ]; then
	echo "There's already an installation of Java JDK in ${JAVA_INSTALL_PREFIX}."
    echo "Uninstall the currently installed JDK before running this script."
	exit 0
fi

yum install -y curl

mkdir -p ${JAVA_INSTALL_PREFIX}

curl -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_MINOR_VERSION}-b17/${JAVA_ARCHIVE} -o /${JAVA_ARCHIVE}
tar -xf /${JAVA_ARCHIVE} -C ${JAVA_INSTALL_PREFIX}
rm /${JAVA_ARCHIVE}

chown -R root:root ${JAVA_INSTALL_PREFIX}
chmod -R u=rwX,g=rwX,o=rX ${JAVA_INSTALL_PREFIX}

if [[ ${SELINUX_ENABLED} ]]; then
	chcon -R -u system_u ${JAVA_INSTALL_PREFIX}
fi

update-alternatives --install "/usr/bin/java"   "java"                                    "${JAVA_INSTALL}/bin/java"   1
update-alternatives --install "/usr/bin/java"   "java-1.${JAVA_MAJOR_VERSION}.0"          "${JAVA_INSTALL}/bin/java"   1
update-alternatives --install "/usr/bin/java"   "java-1.${JAVA_MAJOR_VERSION}.0-oracle"   "${JAVA_INSTALL}/bin/java"   1
update-alternatives --install "/usr/bin/javac"  "javac"                                   "${JAVA_INSTALL}/bin/javac"  1
update-alternatives --install "/usr/bin/javac"  "javac-1.${JAVA_MAJOR_VERSION}.0"         "${JAVA_INSTALL}/bin/javac"  1
update-alternatives --install "/usr/bin/javac"  "javac-1.${JAVA_MAJOR_VERSION}.0-oracle"  "${JAVA_INSTALL}/bin/javac"  1
update-alternatives --install "/usr/bin/javaws" "javaws"                                  "${JAVA_INSTALL}/bin/javaws" 1
update-alternatives --install "/usr/bin/javaws" "javaws-1.${JAVA_MAJOR_VERSION}.0"        "${JAVA_INSTALL}/bin/javaws" 1
update-alternatives --install "/usr/bin/javaws" "javaws-1.${JAVA_MAJOR_VERSION}.0-oracle" "${JAVA_INSTALL}/bin/javaws" 1
update-alternatives --install "/usr/bin/jre"    "jre"                                     "${JAVA_INSTALL}/jre"        1
update-alternatives --install "/usr/bin/jre"    "jre-1.${JAVA_MAJOR_VERSION}.0"           "${JAVA_INSTALL}/jre"        1
update-alternatives --install "/usr/bin/jre"    "jre-1.${JAVA_MAJOR_VERSION}.0-oracle"    "${JAVA_INSTALL}/jre"        1

chown -R root:root ${JAVA_INSTALL}

chmod a+x /usr/bin/java
chmod a+x /usr/bin/javac
chmod a+x /usr/bin/javaws

export JAVA_HOME=${JAVA_INSTALL}/jre
cat >/etc/profile.d/oracle-java-${JAVA_MAJOR_VERSION}.sh <<< "export JAVA_HOME=${JAVA_HOME}"

java -version
