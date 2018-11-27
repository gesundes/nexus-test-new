#!/bin/bash

apt update
apt install openjdk-8-jdk nfs-common -y
useradd -s /bin/false -d /opt/nexus nexus

wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar xfz latest-unix.tar.gz -C /opt
mv /opt/nexus-* /opt/nexus
chown -R nexus:nexus /opt/nexus*
chown -R nexus:nexus /opt/sonatype*

cat > /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=nexus service
After=cloud-final.service

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=cloud-init.target
EOF

systemctl daemon-reload
systemctl enable nexus.service
systemctl start nexus.service
