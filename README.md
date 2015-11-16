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

Components:
* Installs Oracle Java 8 JDK for 64-bit
 * Component: java8_64
* Installs Oracle Java 7 JDK for 64-bit
 * Component: java7_64
