#!/bin/bash
apt update
wget https://git.io/vpn -O openvpn-install.sh
chmod +x openvpn-install.sh
echo "" | bash openvpn-install.sh