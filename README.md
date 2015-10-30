#CentOS Equip
###Set of scripts for configuring common applications on CentOS inspired by the [ubuntu-equip GitHub project](https://github.com/aglover/ubuntu-equip)
###At the time of writing this, the latest CentOS distribution is CentOS 7 which is the CentOS release these scripts have been written for.
###Since CentOS doesn't share the same affinity for sudo that Ubuntu does, these scripts are meant to be ran as root. Commands have been
###prefixed with sudo in the event that they are being ran as a non-priveleged user, but sudo configuration should be done prior to using these scripts.

Component installation: See possible components below
`wget --no-check-certificate https://github.com/brian-dlee/centos-equip/raw/master/equip.sh && bash equip.sh COMPONENT [COMPONENT]...`

* Java 8 64-bit
 * Installs Oracle Java 8 JDK for 64-bit
 * COMPONENT: java8-64
