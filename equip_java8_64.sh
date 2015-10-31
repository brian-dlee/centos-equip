#!/bin/sh

# Equip 64-bit Java 8u66 on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: java8_64
# To run, see https://github.com/brian-dlee/centos-equip

if [ -d "/usr/lib/jvm/" ]; then
	echo "There's already an installation of Java JDK in /usr/lib/jvm."
    echo "Uninstall the currently installed JDK before running this script."
	exit 0
fi

sudo yum install -y curl

curl -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz -o jdk-8-linux-x64.tar.gz
tar -xvf jdk-8-linux-x64.tar.gz

sudo mkdir -p /usr/lib/jvm
sudo mv ./jdk1.8.0_66 /usr/lib/jvm/

sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_66/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_66/bin/javac" 1
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0_66/bin/javaws" 1

sudo chmod a+x /usr/bin/java
sudo chmod a+x /usr/bin/javac
sudo chmod a+x /usr/bin/javaws
sudo chown -R root:root /usr/lib/jvm/jdk1.8.0_66

rm jdk-8-linux-x64.tar.gz

java -version
