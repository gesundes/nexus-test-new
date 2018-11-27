#!/bin/bash
useradd openvpn
echo "openvpn:openvpn" | chpasswd

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

apt update && DEBIAN_FRONTEND=noninteractive apt install openvpn easy-rsa iptables-persistent -y

#Configure iptables
cat > /etc/iptables/rules.v4 <<EOF
*nat
:PREROUTING ACCEPT [41:2519]
:INPUT ACCEPT [18:1004]
:OUTPUT ACCEPT [101:9220]
:POSTROUTING ACCEPT [101:9220]
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
COMMIT
EOF

# Configure OpenVPN
cp -r /usr/share/easy-rsa /etc/openvpn

cd /usr/share/easy-rsa
cp openssl-1.0.0.cnf openssl.cnf
source vars
./clean-all
./pkitool --initca
cp ./keys/ca.crt /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu/ca.crt
./pkitool --server server
./build-dh
cp ./keys/* /etc/openvpn

cat > /etc/openvpn/server.conf <<EOF
port 1194
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.8.0.0 255.255.255.0
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
verify-client-cert none
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
status openvpn-status.log
verb 3
push "route 10.0.0.0 255.255.0.0"
push "dhcp-option DNS 10.0.0.2"
EOF
sleep 10

systemctl daemon-reload
systemctl start openvpn
systemctl start openvpn
systemctl enable openvpn
