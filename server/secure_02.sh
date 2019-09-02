echo -e "Secure"
apt -y full-upgrade
apt install -y apparmor-profiles apparmor-utils auditd deborphan
apt remove -y popularity-contest unattended-upgrades
sed -i -e '/motd=/ s/session/#session/' /etc/pam.d/login
echo -e "Configuring home directories and shell access..."
sed -i -e '/^DIR_MODE=/ s/=[0-9]*\+/=0700/' /etc/adduser.conf
sed -i -e '/^UMASK\s\+/ s/022/077/' /etc/login.defs
echo -e "Disable shell access for new users (not affecting the existing admin user).""
sed -i -e '/^SHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/default/useradd
sed -i -e '/^DSHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/adduser.conf
sed -i -e '/pam_motd.so/s/session/#session/' /etc/pam.d/sshd
sed -i -e 's/#Banner none/Banner \/etc\/issue.net' /etc/ssh/sshd_config
cat > /etc/issue.net << FOOD
***************************************************************************
NOTICE

This computer system is the private property of the (your name or company). 
It is for authorized use only.

By using this system, you consent to interception, monitoring, recording,
copying, auditing, inspection, and disclosure of actions performed on
system.  Unauthorized or improper use of this system may result in civil
action. By continuing to use this system you indicate your awareness of and
consent to these terms and conditions of use.

LOG OFF IMMEDIATELY if you do NOT agree to the conditions in this warning.
****************************************************************************

FOOD
echo -e "AppArmor"
aa-enforce /etc/apparmor.d/usr.sbin.avahi-daemon
aa-enforce /etc/apparmor.d/usr.sbin.dnsmasq
aa-enforce /etc/apparmor.d/bin.ping
aa-enforce /etc/apparmor.d/usr.sbin.rsyslogd
echo -e "auditd"
cat > /etc/audit/rules.d/tmp-monitor.rules << FOOD
-w /tmp/ -p wa -k tmp_write
-w /tmp/ -p x -k tmp_exec
FOOD
cat  > /etc/audit/rules.d/admin-home-watch.rules << FOOD
-a always,exit -F dir=/home/ -F uid=0 -C auid!=obj_uid -k admin_home_user
FOOD
augenrules
systemctl restart auditd.service
echo -e "Disable Apport error reporting service"
systemctl stop apport.service
systemctl disable apport.service
systemctl mask apport.service
sed -i -e '/^enabled=1$/ s/1/0/' /etc/default/apport
echo "Disable the Whoopsie service"
sed -i -e '/^enabled=1$/ s/1/0/' /etc/default/whoopsie
systemctl stop whoopsie.service
systemctl disable whoopsie.service
systemctl mask whoopsie.service
echo "Remove Popularity Contest service (removed above)"
apt remove -y popularity-contest
echo -e "UFW Firewall"
ufw status verbose
ufw allow from 127.0.0.1
ufw allow from 192.168.0.0/24 to any app OpenSSH
ufw deny from any to any app OpenSSH
ufw logging on
ufw enable
shutdown -h 1; exit
