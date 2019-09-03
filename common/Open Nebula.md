# OpenNebula

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*
-  [OpenNebula Home](https://opennebula.org)
-  [GitHub](https://github.com/OpenNebula)

>OpenNebula is an open-source management platform to build IaaS private, public and hybrid clouds. Installing a cloud from scratch could be a complex process, in the sense that many components and concepts are involved. The degree of familiarity with these concepts (system administration, infrastructure planning, virtualization management...) will determine the difficulty of the installation process.

## Install

[Front-end Installation](http://docs.opennebula.org/5.8/deployment/opennebula_installation/frontend_installation.html)

```Bash
sudo -i
echo "Install"
wget -q -O- https://downloads.opennebula.org/repo/repo.key | apt-key add -
echo "deb http://downloads.opennebula.org/repo/5.8/Ubuntu/18.04 stable opennebula" > /etc/apt/sources.list.d/opennebula.list
apt update
apt install -y opennebula opennebula-sunstone opennebula-gate opennebula-flow lynx
/usr/share/one/install_gems
echo "Step 5. Enabling MySQL/MariaDB (Optional)"
su oneadmin
echo "oneadmin:mypassword" > ~/.one/one_auth
exit
echo "Firewall configuration"
cat > /etc/ufw/applications.d/open_nebula << FOOD
[OpenNebula]
title=Management platform to build IaaS private, public and hybrid clouds
description=OpenNebula is an open-source management platform to build IaaS private, public and hybrid clouds.
ports=2474,2633,5030,9869,29876/tcp
FOOD
ufw app update OpenNebula
ufw allow from 10.0.0.0/8 to any app OpenNebula
ufw allow from 172.16.0.0/12 to any app OpenNebula
ufw allow from 192.168.0.0/16 to any app OpenNebula
ufw deny from any to any app OpenNebula
ufw reload
echo "Start and Test System"
systemctl start opennebula
systemctl start opennebula-sunstone
su oneadmin
oneuser show
exit
exit
lynx http://127.0.0.1:9869
```

