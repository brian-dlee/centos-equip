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

echo "Running installer Java Version ${JAVA_MAJOR_VERSION}u${JAVA_MINOR_VERSION}"

JAVA_PREFIX="/usr/lib/jvm"
JAVA_INSTALL="${JAVA_PREFIX}/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_MINOR_VERSION}"
JAVA_ARCHIVE="jdk-${JAVA_MAJOR_VERSION}-linux-x64.tar.gz"

if [ -d ${JAVA_INSTALL} ]; then
	echo "There's already an installation of Java JDK at ${JAVA_INSTALL}."
    echo "Uninstall the currently installed JDK before running this installer."
	exit 0
fi

yum install -y -q curl

mkdir -p ${JAVA_PREFIX}

echo http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_MINOR_VERSION}-${JAVA_MTN_KEY}/${JAVA_ARCHIVE}
curl --silent -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_MINOR_VERSION}-b17/jdk-${JAVA_MAJOR_VERSION}u${JAVA_MINOR_VERSION}-linux-x64.tar.gz -o /${JAVA_ARCHIVE}
tar -zxf /${JAVA_ARCHIVE} -C ${JAVA_PREFIX}
rm /${JAVA_ARCHIVE}

chown -R root:root ${JAVA_PREFIX}
chmod -R u=rwX,g=rwX,o=rX ${JAVA_PREFIX}

if [[ ${SELINUX_ENABLED} == 1 ]]; then
	chcon -R -u system_u ${JAVA_PREFIX}
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

export JAVA_HOME=${JAVA_INSTALL}
cat >/etc/profile.d/oracle-java-${JAVA_MAJOR_VERSION}.sh <<< "export JAVA_HOME=${JAVA_HOME}"

java -version
