#!/bin/bash
# Ubuntu 20.04 LTS || Ubuntu 18.04.4 LTS (head -n1 /etc/issue || tail -n1 /etc/lsb-release)
#
# whob -gnp 8.8.8.8 => 8.8.8.8 | origin-as 15169 (8.8.8.0/24) | as-path 2905 15169 | LVLT-GOGL-8-8-8 | Google LLC 
#
export DEBIAN_FRONTEND=noninteractive && (apt-get -q -q -y update && apt-get -q -q -y install whois lft dnsutils) > /dev/null 2>&1

exit 0
