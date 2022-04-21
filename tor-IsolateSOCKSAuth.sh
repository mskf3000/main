#!/usr/bin/env bash

cat << EOF > /etc/tor/torrc
Log notice syslog
ClientOnly
DataDirectory /var/lib/tor
SocksPort 0.0.0.0:59050 IsolateDestAddr IsolateDestPort IsolateClientProtocol IsolateClientAddr IsolateSOCKSAuth
SocksPort [::]:59050 IsolateDestAddr IsolateDestPort IsolateClientProtocol IsolateClientAddr IsolateSOCKSAuth
EOF

systemctl restart tor
