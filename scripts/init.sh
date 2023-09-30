#!/bin/bash
chmod 700 *.sh
source config.sh

#install
sudo apt update
sudo apt install -y wireguard qrencode net-tools tree

# make directory
mkdir -p $VPN_SERVER_PATH
mkdir -p $VPN_CLIENT_PATH

# nat settings
# /etc/sysctl.conf
if [[ $(cat /proc/sys/net/ipv4/ip_forward) -ne 1 ]]; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi
sudo iptables -t nat -A POSTROUTING -o $EXTERNAL_INTERFACE -j MASQUERADE


# server settings
wg genkey | sudo tee $VPN_SERVER_PATH/default.key | wg pubkey | sudo tee $VPN_SERVER_PATH/default.key.pub

cat << EOF > $VPN_SERVER_PATH/wg0.conf
[Interface]
Address = $VPN_SERVER_CIDR
PrivateKey = `cat $VPN_SERVER_PATH/default.key`
ListenPort = $VPN_SERVER_PORT

EOF

cat << EOF > $VPN_SERVER_PATH/start.sh
wg-quick up $VPN_SERVER_PATH/wg0.conf
EOF

cat << EOF > $VPN_SERVER_PATH/restart.sh
wg-quick down $VPN_SERVER_PATH/wg0.conf && wg-quick up $VPN_SERVER_PATH/wg0.conf
EOF

cat << EOF > $VPN_SERVER_PATH/monitoring.sh
watch -n 1 wg
EOF

chmod 700 $VPN_SERVER_PATH/*.sh