#!/bin/sh

# Equip Maven Java Project Manager on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: Apache Maven
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
    echo >&2 "! Failed installation, entering cleanup."
    rm -f /apache-maven-3.3.3-bin.tar.gz 2>/dev/null
    exit 1
}

trap 'cleanup' ERR

if [ ! -d "/usr/lib/jvm/" ]; then
	echo "There is no installation of Java JDK in /usr/lib/jvm."
    echo "Install a JDK (OpenJDK 1.7 or above) before running this script."
	exit 1
fi

echo "Installing Maven."

yum install -y -q curl

curl --silent -L http://ftp.wayne.edu/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz -o /apache-maven-3.3.3-bin.tar.gz
tar -zxf /apache-maven-3.3.3-bin.tar.gz -C /usr/local/
rm -f /apache-maven-3.3.3-bin.tar.gz

chown -R root:root /usr/local/apache-maven-3.3.3
chmod -R u=rwX,g=rwX,o=rX /usr/local/apache-maven-3.3.3

if [[ $SELINUX_ENABLED ]]; then
	chcon -R -u system_u /usr/local/apache-maven-3.3.3
fi

if [[ -z $JAVA_HOME ]]; then
    export JAVA_HOME=$(update-alternatives --display java | grep "\`best'" | egrep -o '/.+' | sed 's/bin\/java.*//')
fi

export PATH=$PATH:/usr/local/apache-maven-3.3.3/bin/
cat >/etc/profile.d/maven.sh <<< 'export PATH=$PATH:/usr/local/apache-maven-3.3.3/bin/'

mvn --version
