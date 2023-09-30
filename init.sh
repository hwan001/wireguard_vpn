#!/bin/bash

EXTERNAL_INTERFACE=eth0
VPN_SERVER_PATH=/etc/wireguard/server
VPN_SERVER_CIDR=192.168.0.0/16
VPN_SERVER_PORT=11940

mkdir -p $VPN_SERVER_PATH
wg genkey | sudo tee $VPN_SERVER_PATH/default.key | wg pubkey | sudo tee $VPN_SERVER_PATH/default.key.pub

# /etc/sysctl.conf
if [[ $(cat /proc/sys/net/ipv4/ip_forward) -ne 1 ]]; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi
sudo iptables -t nat -A POSTROUTING -o $EXTERNAL_INTERFACE -j MASQUERADE

cat << EOF > $VPN_SERVER_PATH/wg0.conf
[Interface]
Address = $VPN_SERVER_CIDR
PrivateKey = `cat $VPN_SERVER_PATH/default.key`
ListenPort = $VPN_SERVER_PORT

EOF