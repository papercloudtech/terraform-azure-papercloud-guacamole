#!/usr/bin/env bash
#
# Author: PaperCloud Developers
# Created on: ...
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -y
apt install -y xfce4 xfce4-goodies
apt install -y xrdp
adduser xrdp ssl-cert
systemctl restart xrdp
apt install -y build-essential libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev freerdp2-dev libpango1.0-dev libssh2-1-dev tomcat9
wget https://downloads.apache.org/guacamole/1.5.5/source/guacamole-server-1.5.5.tar.gz
tar -xzf guacamole-server-1.5.5.tar.gz
cd guacamole-server-1.5.5
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd
wget https://downloads.apache.org/guacamole/1.5.5/binary/guacamole-1.5.5.war
mv guacamole-1.5.5.war /var/lib/tomcat9/webapps/guacamole.war
systemctl restart tomcat9
mkdir /etc/guacamole

echo "guacd-hostname: localhost
guacd-port: 4822
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml" | tee /etc/guacamole/guacamole.properties

echo "<user-mapping>
    <authorize username=\"guacamole\" password=\"Guacamole@8080\">
        <connection name=\"Ubuntu Desktop\">
            <protocol>rdp</protocol>
            <param name=\"hostname\">localhost</param>
            <param name=\"port\">3389</param>
            <param name=\"ignore-cert\">true</param>
            <param name=\"enable-clipboard\">true</param>
        </connection>
    </authorize>
</user-mapping>" | tee /etc/guacamole/user-mapping.xml

systemctl daemon-reload
systemctl restart guacd
systemctl restart tomcat9

