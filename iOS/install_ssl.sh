#!/bin/sh

apk update
apk upgrade
apk add openssl stunnel
mkdir -p /run/stunnel

openssl genrsa -out ~/RootCAKey.pem 2048
openssl req -x509 -sha256 -new -nodes -key ~/RootCAKey.pem -days 3650 -out RootCACert.pem
chmod 600 ~/RootCAKey.pem
chmod 600 ~/RootCACert.pem

PSK=$(base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 44)
echo "user:${PSK}" > ~/psk.txt
chmod 600 ~/psk.txt

echo -n "
cert = /root/RootCACert.pem
key = /root/RootCAKey.pem

# stunnel's SOCKS is encapsulated in TCP; act closer to UDP with TCP_NODELAY=1.
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

# Prefer weaker cryptography strength, since we're CPU limited.
fips = no

foreground = yes

# Due to mobile internet drop-outs, anticipate non-immediate DNS resolving.
delay = yes

[SOCKS Client Direct]
accept = :::9050

[SOCKS Client Transparent IPv4]
accept = 127.0.0.1:9051
protocol = socks

[SOCKS Client Transparent IPv6]
accept = ::1:9051
protocol = socks
" > /etc/stunnel/stunnel.conf