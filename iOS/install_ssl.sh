#!/bin/bash
set -eu

apk update
apk upgrade
apk add openssl stunnel
mkdir -p /run/stunnel
openssl genrsa -out ~/RootCAKey.pem 2048
openssl req -x509 -sha256 -new -nodes -key ~/RootCAKey.pem -days 3650 -out RootCACert.pem
chmod 600 {~/RootCAKey.pem,~/RootCACert.pem}

echo -n "
cert = /root/RootCACert.pem
key = /root/RootCAKey.pem

# stunnel's SOCKS5 is encapsulated in TCP; act closer to UDP with TCP_NODELAY=1.
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

# If stunnel works, set to: no
foreground = yes

# Expect that DNS resolving won't be immediate, due to mobile internet drop-outs.
delay = yes

[hotspot server]
accept = localhost:4540
protocol = socks
PSKsecrets = /root/psk.txt
" > /etc/stunnel/stunnel.conf