#CentOS Equip
###Set of scripts for configuring common applications on CentOS
###Inspired by the [ubuntu-equip](https://github.com/aglover/ubuntu-equip) GitHub project

At the time of writing this, the latest CentOS distribution is CentOS 7 which is the CentOS release these scripts have been written for.
Since CentOS doesn't share the same affinity for sudo that Ubuntu does, these scripts are meant to be ran as root.

Component installation
* Download equip script:
`wget --no-check-certificate https://github.com/brian-dlee/centos-equip/raw/master/equip.sh`
* Install components:
`bash equip.sh COMPONENT [COMPONENT]...`

Note: Dependencies install automatically.

Components:
* Installs 64-bit Oracle Java 7 JDK
 * Component: `java` or `java:7`
* Installs 64-bit Oracle Java 8 JDK
 * Component: `java:8`
* Installs Apache Maven 3.3.9
 * Component: `maven` or `maven:3`
 * Depends on `java:7`
* Installs Apache Tomcat 7.0.65
 * Component: `tomcat` or `tomcat:7`
 * Depends on `java:7`
* Installs Apache Tomcat 8.0.28
 * Component: `tomcat:8`
 * Depends on `java:7`
