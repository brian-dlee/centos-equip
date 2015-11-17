#!/bin/sh

# Equip Apache Tomcat 8 on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: Apache Tomcat
# To run, see https://github.com/brian-dlee/centos-equip

TC_VERSION=8.0.28
TC_ARCHIVE=apache-tomcat-${TC_VERSION}.tar.gz
TC_INSTALL=/usr/local/src/apache-tomcat-${TC_VERSION}

persistant_vars=()

function cleanup {
    rm -f /${TC_ARCHIVE} 2>/dev/null
    exit 1
}

trap 'cleanup' ERR

if [ ! -d "/usr/lib/jvm/" ]; then
	echo "There is no installation of Java JDK in /usr/lib/jvm."
    echo "Install a JDK (OpenJDK 1.7 or above) before running this script."
	exit 1
fi

yum install -y curl

curl -L http://mirror.symnds.com/software/Apache/tomcat/tomcat-8/v${TC_VERSION}/bin/${TC_ARCHIVE} -o /${TC_ARCHIVE}
tar -zxf /${TC_ARCHIVE} -C /usr/local/src
rm -f /${TC_ARCHIVE}

if [[ -z ${CATALINA_HOME} ]]; then
    catalina_home_var="CATALINA_HOME=/usr/local/share/tomcat"
    export ${catalina_home_var}
else
    catalina_home_var="CATALINA_HOME=${CATALINA_HOME}"
fi

if [[ -z ${CATALINA_BASE} ]]; then
    catalina_base_var="CATALINA_BASE=/usr/local/share/tomcat"
    export ${catalina_base_var}
else
    catalina_base_var="CATALINA_BASE=${CATALINA_BASE}"
fi

${persistant_vars}+=(${catalina_home_var} ${catalina_base_var})

if [[ ! -e ${CATALINA_HOME} ]]; then
    mkdir -p ${CATALINA_HOME}
fi

tar -xf /${TC_ARCHIVE} -C /usr/local/src/

ln -s ${TC_INSTALL}/conf /etc/tomcat

ln -s ${TC_INSTALL}/logs /var/logs/tomcat

ln -s ${TC_INSTALL}/bin ${CATALINA_HOME}/bin
ln -s ${TC_INSTALL}/lib ${CATALINA_HOME}/lib
ln -s ${TC_INSTALL}/temp ${CATALINA_HOME}/temp
ln -s ${TC_INSTALL}/webapps ${CATALINA_HOME}/webapps
ln -s ${TC_INSTALL}/work ${CATALINA_HOME}/work

mkdir /var/lib/tomcat
ln -s ${CATALINA_HOME}/temp /var/lib/tomcat/temp
ln -s ${CATALINA_HOME}/webapps /var/lib/tomcat/webapps
ln -s ${CATALINA_HOME}/work /var/lib/tomcat/work

if [[ -z ${JAVA_HOME} ]]; then
    java_home_var="JAVA_HOME=$(update-alternatives --display java | grep "\`best'" | egrep -o '/.+' | sed 's/bin\/java.*//')"
    export ${java_home_var}
else
    java_home_var="JAVA_HOME=${JAVA_HOME}"
fi

${persistant_vars}+=(${java_home_var})

cat > /etc/systemd/system/tomcat.service <<< "
[Unit]
Description=Tomcat 8 Service
After=network.target

[Service]
Type=simple
User=tomcat
ExecStart=${CATALINA_HOME}/bin/startup.sh
ExecStop=${CATALINA_HOME}/bin/shutdown.sh
Restart=on-abort

[Install]
WantedBy=multi-user.target
"

groupadd tomcat
useradd -g tomcat -d ${CATALINA_HOME} -r tomcat

chown -R tomcat:tomcat ${TC_INSTALL}
chmod -R u=rwX,g=rwX,o=rX ${CATALINA_HOME}

if [[ ${SELINUX_ENABLED} ]]; then
	chcon -R -u system_u ${CATALINA_HOME}
fi
