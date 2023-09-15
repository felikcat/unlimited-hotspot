#!/bin/bash
set -eu

apk update
apk upgrade
apk add openssh
ssh-keygen -t ed25519
mv ~/.ssh/id_ed25519 /etc/ssh/ssh_host_ed25519_key
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 700 -R ~/.ssh
chmod 600 ~/.ssh/authorized_keys
cp ~/.ssh/id_ed25519.pub ~/client.pub
# Grant permissions for 'root' to be used for sshd.
sed -i s/root:!/"root:*"/g /etc/shadow

echo -n "
AuthorizedKeysFile /root/.ssh/authorized_keys
Compression no            # x86 emulation incurs heavy CPU usage, don't add onto that
GatewayPorts yes          # Allow local port forwarding
ListenAddress 0.0.0.0     # Use local IP
PasswordAuthentication no
PermitRootLogin without-password
PermitTunnel yes          # Allow reverse tunneling
Port 43188                # Custom port, 22 won't work
PubkeyAuthentication yes  # Allow SSH public key auth
UseDNS no                 # Do DNS resolving on the client instead
" > /etc/ssh/sshd_config
