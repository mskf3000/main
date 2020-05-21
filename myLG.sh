#!/bin/bash
# myLG v0.2.7

# CentOS Linux 7 (Core) (cat /etc/*release)
yum update -y -q && yum install -y -q libpcap-devel && (cd /usr/lib64/ && ln -s {libpcap.so,libpcap.so.0.8}) && rpm -ivh --nodeps https://mylg.io/dl/linux/mylg-0-2.7.x86_64.rpm


# Ubuntu 20.04 LTS || Ubuntu 18.04.4 LTS (head -n1 /etc/issue || tail -n1 /etc/lsb-release)
export DEBIAN_FRONTEND=noninteractive && apt-get update -q -q -y && apt-get install -q -q -y apt-utils gdebi-core wget && (cd $(mktemp -d) && wget -qO mylg.deb https://mylg.io/dl/linux/mylg.amd64.deb && gdebi -q -n mylg.deb && mylg version)
