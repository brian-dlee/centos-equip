#!/bin/sh

# Equip 64-bit Java 7u65 on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: java7_64
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
	rm -f /jdk-7-linux-x64.tar.gz 2>/dev/null
    exit 1
}

trap 'cleanup' ERR

if [ -d "/usr/lib/jvm/" ]; then
	echo "There's already an installation of Java JDK in /usr/lib/jvm."
    echo "Uninstall the currently installed JDK before running this script."
	exit 0
fi

yum install -y curl

mkdir -p /usr/lib/jvm

curl -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u65-b17/jdk-7u65-linux-x64.tar.gz -o /jdk-7-linux-x64.tar.gz
tar -xvf /jdk-7-linux-x64.tar.gz -C /usr/lib/jvm
rm /jdk-7-linux-x64.tar.gz

chown -R root:root /usr/lib/jvm
chmod -R u=rwX,g=rwX,o=rX /usr/lib/jvm

if [[ $SELINUX_ENABLED ]]; then
	chcon -R -u system_u /usr/lib/jvm
fi

update-alternatives --install "/usr/bin/java"   "java"                "/usr/lib/jvm/jdk1.7.0_65/bin/java"   1
update-alternatives --install "/usr/bin/java"   "java-1.7.0"          "/usr/lib/jvm/jdk1.7.0_65/bin/java"   1
update-alternatives --install "/usr/bin/java"   "java-1.7.0-oracle"   "/usr/lib/jvm/jdk1.7.0_65/bin/java"   1
update-alternatives --install "/usr/bin/javac"  "javac"               "/usr/lib/jvm/jdk1.7.0_65/bin/javac"  1
update-alternatives --install "/usr/bin/javac"  "javac-1.7.0"         "/usr/lib/jvm/jdk1.7.0_65/bin/javac"  1
update-alternatives --install "/usr/bin/javac"  "javac-1.7.0-oracle"  "/usr/lib/jvm/jdk1.7.0_65/bin/javac"  1
update-alternatives --install "/usr/bin/javaws" "javaws"              "/usr/lib/jvm/jdk1.7.0_65/bin/javaws" 1
update-alternatives --install "/usr/bin/javaws" "javaws-1.7.0"        "/usr/lib/jvm/jdk1.7.0_65/bin/javaws" 1
update-alternatives --install "/usr/bin/javaws" "javaws-1.7.0-oracle" "/usr/lib/jvm/jdk1.7.0_65/bin/javaws" 1
update-alternatives --install "/usr/bin/jre"    "jre"                 "/usr/lib/jvm/jdk1.7.0_65/jre"        1
update-alternatives --install "/usr/bin/jre"    "jre-1.7.0"           "/usr/lib/jvm/jdk1.7.0_65/jre"        1
update-alternatives --install "/usr/bin/jre"    "jre-1.7.0-oracle"    "/usr/lib/jvm/jdk1.7.0_65/jre"        1

chown -R root:root /usr/lib/jvm/jdk1.7.0_65

chmod a+x /usr/bin/java
chmod a+x /usr/bin/javac
chmod a+x /usr/bin/javaws

java -version
