#!/bin/bash
# https://team-cymru.com/community-services/ip-asn-mapping/
# netcat whois.cymru.com 43 < ips.txt | sort -n > cymru-whois.txt
# host 38.229.36.132 | awk '{print $NF}' => whois.cymru.com

(exec 3<> /dev/tcp/38.229.36.132/43;printf 'begin\nverbose\n%s\nend\n' "$(< ips.txt)" >&3;cat <&3) | grep -vF 'Bulk mode' | sort -u > cymru-whois.txt

exit 0
