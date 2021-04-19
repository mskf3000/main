#!/bin/bash
################################################################################
# Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-1021-gcp x86_64)
################################################################################
# @OS: Ubuntu 20.04 LTS
# @date: seg 19 abr 2021 14:28:57 -03
# @author: M5KF300 mskf3000@hotmail.com
# @title: get ip info
# @version: 1.0
# @description: get ip info by dns
################################################################################

dig +short TXT 8.8.8.8.asn.routeviews.org
dig +short TXT 8.8.8.8.aspath.routeviews.org
dig +short TXT 8.8.8.8.all.ascc.dnsbl.bit.nl
dig +short TXT 8.8.8.8.asn.routeviews.org
dig +short TXT 8.8.8.8.origin.asn.cymru.com
dig +short TXT 8.8.8.8.origin.asn.shadowserver.org
dig +short TXT 8.8.8.8.origin.asn.spameatingmonkey.net
dig +short TXT 8.8.8.8.query.senderbase.org
dig +short TXT 8.8.8.8.zz.countries.nerd.dk

whois -h asn.shadowserver.org origin 8.8.8.8
whois -h asn.shadowserver.org prefix 15169
