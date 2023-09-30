#!/bin/bash
source config.sh
source user.sh

VPN_CLIENT_PATH=$VPN_CLIENT_PATH/$VPN_CLIENT_NAME

mkdir -p $VPN_CLIENT_PATH
wg genkey | sudo tee $VPN_CLIENT_PATH/default.key | wg pubkey | sudo tee $VPN_CLIENT_PATH/default.key.pub

cat << EOF > $VPN_CLIENT_PATH/default.conf
[Interface]
PrivateKey = `cat $VPN_CLIENT_PATH/default.key`
Address = $VPN_CLIENT_CIDR
DNS = 1.1.1.1, 1.0.0.1, 8.8.8.8

[Peer]
PublicKey = `cat $VPN_SERVER_PATH/default.key.pub`
AllowedIPs = 0.0.0.0/0
Endpoint = vpn.hwan001.net:11940
EOF

cat << EOF > $VPN_CLIENT_PATH/qrcode.sh
qrencode -t ansiutf8 < $VPN_CLIENT_PATH/default.conf
EOF

chmod 700 $VPN_CLIENT_PATH/qrcode.sh

cat << EOF >> $VPN_SERVER_PATH/wg0.conf
[Peer]
PublicKey = `cat $VPN_CLIENT_PATH/default.key.pub`
AllowedIPs = $VPN_CLIENT_CIDR

EOF