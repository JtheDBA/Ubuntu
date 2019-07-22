# Ubuntu 18.04 Server on Synology DS-218+ in Virtual Machine Manager
## Purpose

This virtual machine will act as a centralized location for:

* cached apt packages (apt-cacher-ng)
* software for Ubuntu Linux
* .iso images that can be prepared through zsync and completed on the Synology DS-218+

Note: I had originally created this using Virtual Box then imported as an appliance but I probably should've simply installed it using the interface.

## Before Creating the VM

Since the purpose of this virtual machine is to live on a physical system containing files and services outside the virtual machine we should perform a few things before continuing:

1.  create a download folder on the  host
2.  download the base `ubuntu-18.04-mini-amd64.iso` Ubuntu Mini image and `gparted-live-0.33.0-1-i686.iso` GParted image (for virtual disk optimization)

I created a download shared folder on the host for our home network. This folder will contain all software and disk images. Since this share can be rebuilt I do not include it in any backups on the host. All Windows and Linux physical computers mount this location locally so it can be used as a centralized folder for all software.

## Create VM

80 GB

## Install OS

Defaults except:

Partitioning:
- /dev/sda:
  - 2G primary ext4 /boot bootable
  - 100% primary Linux LVM

Volume Group: root_vg

Logical Volumes:
- lv_swap 4G swap
- lv_root 8G ext4 /
- lv_home 2G ext4 /home
- lv_temp 8G ext4 /tmp
- lv_var 4G ext4 /

Install OpenSSH Server

## Configure - Step 1

These steps are easier if done via cut and paste. Use `ip a` to obtain the IP address within the VM then use PuTTY or other SSH client to finish. 

The first two steps install the virtualization tools and the apt package cacher utilities. The apt package cacher is optional but recommended if there are three or more Ubuntu machines in your network or if you do frequent virtual environment updates from base images. The central server usually gets 60 to 70 percent cache hits and saves about a gig or two of bandwidth. Worth it IMO.

This step also sets that static IP for the VM.

```Shell
sudo -i
add-apt-repository universe
apt update
apt install -y qemu-guest-agent
apt install -y apt-cacher-ng cifs-utils deborphan libcups2 lynx mc nfs-common p7zip-full p7zip-rar rar samba-common tree unzip zip zsync
mv /etc/netplan/*.yaml 33-init.yaml
sed -ie '/#/!d' /etc/netplan/33-init.yaml
cat >> /etc/netplan/33-init.yaml << FOOD
network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
       dhcp4: no
       addresses: [192.168.0.184/24]
       gateway4: 192.168.0.1
       nameservers:
        addresses: [8.8.8.8,8.8.4.4]
       optional: true
FOOD
shutdown -r 1; exit
exit
```

## Configure - Step 2
### Prepare CD images

I like to keep copies of the CD images for most Ubuntu distributions at the LTS level and current versions of the Ubuntu desktop, Ubuntu mate desktop and Ubuntu desktop. I found the most efficient way to do this is to use `zsync` to build CD images from local CD images than either let `zsync` finish or use it torrent to download the remainder of the CD image.

The following shell script assumes the main desktop image `ubuntu-18.04.2-desktop-amd64.iso` has been downloaded then uses `zsync` to download the remaining pieces for the various distributions:

```Shell
cd /folder
zsync -i ubuntu-18.04.2-desktop-amd64.iso http://releases.ubuntu.com/18.04.2/ubuntu-18.04.2-live-server-amd64.iso.zsync
zsync -i ubuntu-18.04.2-desktop-amd64.iso http://cdimage.ubuntu.com/ubuntu-mate/releases/18.04.2/release/ubuntu-mate-18.04.2-desktop-amd64.iso.zsync
zsync -i ubuntu-18.04.2-desktop-amd64.iso http://cdimage.ubuntu.com/lubuntu/releases/18.04.2/release/lubuntu-18.04.2-desktop-amd64.iso.zsync
zsync -i ubuntu-18.04.2-desktop-amd64.iso http://cdimage.ubuntu.com/xubuntu/releases/18.04.2/release/xubuntu-18.04.2-desktop-amd64.iso.zsync
zsync -i ubuntu-18.04.2-desktop-amd64.iso http://cdimage.ubuntu.com/kubuntu/releases/18.04.2/release/kubuntu-18.04.2-desktop-amd64.iso.zsync
```

### Configure apt-cacher-ng

Finish configuration of `apt-cacher-ng` and install basic minimal packages. Note; if installing from "Mini" everything should be up to date and some steps will fail with "cannot stat '/var/cache/apt/archives/*.deb': No such file or directory"

```
sudo -i
echo 'Acquire::http { Proxy "http://127.0.0.1:3142"; };' | tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxytable
apt update
test -x /var/cache/apt-cacher-ng/_import || mkdir -p -m 2755 /var/cache/apt-cacher-ng/_import
mv -uf /var/cache/apt/archives/*.deb /var/cache/apt-cacher-ng/_import/
chown -R apt-cacher-ng.apt-cacher-ng /var/cache/apt-cacher-ng/_import
lynx http://127.0.0.1:3142/acng-report.html?doImport=Start+Import#bottom
apt full-upgrade -y
apt remove -y popularity-contest unattended-upgrades
apt install -y libcups2 mc nfs-common p7zip-full p7zip-rar rar tree unzip zip zsync
apt update


```
for foo in ubuntu-18.04.2-desktop-amd64.iso kubuntu-18.04.2-desktop-amd64.iso lubuntu-18.04.2-desktop-amd64.iso ubuntu-18.04.2-desktop-amd64.iso ubuntu-18.04.2-live-server-amd64.iso ubuntu-mate-18.04.2-desktop-amd64.iso xubuntu-18.04.2-desktop-amd64.iso
do
mount -o loop /mnt/smb/local/download/${foo} /var/cache/apt-cacher-ng/_import
lynx http://127.0.0.1:3142/acng-report.html?doImport=Start+Import#bottom
umount /var/cache/apt-cacher-ng/_import
done

```

## Configure - Step 3
This procedure assumes you maintain one or more of the .iso images used to install Ubuntu and other distributions maintained via zsync.
The zsync command can be the best way to build an .iso image from a new release using previous releases. It uses existing pieces to build the target .iso image. The zsync can be used one of two ways; update .iso images completely from existing .iso via zsync or use zsync to build the new .iso from existing .iso, cancel the zsync, then finish the download through bit torrent.
All exiting .iso can be imported into apt-cacher-ng.

```
sudo -i


vi /etc/fstab
# SMB
//192.168.0.130/download /mnt/smb/local/download cifs vers=3.0,credentials=/root/credentials.130 0 0

# SMB
//192.168.0.130/download /mnt/smb/local/download cifs credentials=/root/credentials.130,dir_mode=0777,file_mode=0777,vers=3.0 0 0

mount 192.168.0.130:/volume1/download /media/nas/download

192.168.1.214:/volume1/download /media/nas/download nfs4 defaults 0 0
 rsize=8192,wsize=8192,timeo=14,intr
192.168.0.130:/volume1/download on /media/nas/download type nfs4 (rw,relatime,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.184,local_lock=none,addr=192.168.0.130)


mkdir -p /mnt/cifs/local/download
chmod -R 777 /mnt/cifs/local
chmod -R nobody:nogroup /mnt/cifs/local





```
```
ln -s ~/common/upd ~/upd
ln -s ~/common/updone ~/updone
for FOO in upd updone post1
do
ln -s ~/common/${FOO} ~/server/${FOO}
ln -s ~/common/${FOO} ~/desktop/${FOO}
ln -s ~/common/${FOO} ~/vbox/${FOO}
done
ln -s ~/desktop/desktop2 ~/vbox/desktop2
ln -s ~/server/server0 ~/vbox/server0
ln -s ~/server/server1 ~/vbox/server1


#







### Standard "Hardening"
HIGHLIGHT='\033[1;32m'
NC='\033[0m'
echo -e "${HIGHLIGHT}Configure packages...${NC}"
apt update
apt dist-upgrade -y
apt remove -y popularity-contest unattended-upgrades
apt install -y apparmor-profiles apparmor-utils auditd cifs-utils libcups2 lynx mc nfs-common p7zip-full p7zip-rar rar samba-common unzip zip tree
echo -e "${HIGHLIGHT}Configure filesystem and fstab...${NC}"
sed -ie '/\s\/home\s/ s/defaults/defaults,noexec,nosuid,nodev/' /etc/fstab
sed -ie '/\s\/tmp\s/ s/defaults/defaults,nosuid,nodev/' /etc/fstab
chmod 1777 -R /tmp
chown root.root /tmp
echo -e "${HIGHLIGHT}Configuring /etc/ configurations...${NC}"
sed -ie '/^DIR_MODE=/ s/=[0-9]*\+/=0700/' /etc/adduser.conf
sed -ie '/^UMASK\s\+/ s/022/077/' /etc/login.defs
sed -ie '/^SHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/default/useradd
sed -ie '/^DSHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/adduser.conf
sed -ie '/^enabled=1$/ s/1/0/' /etc/default/apport
echo -e "${HIGHLIGHT}Configure su execution...${NC}"
dpkg-statoverride --update --add root adm 4750 /bin/su
echo -e "${HIGHLIGHT}Configuring minimum password requirements...${NC}"
apt install -yf libpam-pwquality
echo -e "${HIGHLIGHT}Configuring apparmor...${NC}"
aa-enforce /etc/apparmor.d/usr.bin.firefox
aa-enforce /etc/apparmor.d/usr.sbin.avahi-daemon
aa-enforce /etc/apparmor.d/usr.sbin.dnsmasq
aa-enforce /etc/apparmor.d/bin.ping
aa-enforce /etc/apparmor.d/usr.sbin.rsyslogd
echo -e "${HIGHLIGHT}Configuring system auditing...${NC}"
if [ ! -f /etc/audit/rules.d/tmp-monitor.rules ]; then
echo "# Monitor changes and executions within /tmp
-w /tmp/ -p wa -k tmp_write
-w /tmp/ -p x -k tmp_exec" > /etc/audit/rules.d/tmp-monitor.rules
fi
if [ ! -f /etc/audit/rules.d/admin-home-watch.rules ]; then
echo "# Monitor administrator access to /home directories
-a always,exit -F dir=/home/ -F uid=0 -C auid!=obj_uid -k admin_home_user" > /etc/audit/rules.d/admin-home-watch.rules
fi
augenrules
systemctl restart auditd.service
echo -e "${HIGHLIGHT}Configuring error reporting...${NC}"
systemctl stop apport.service
systemctl disable apport.service
systemctl mask apport.service
echo -e "${HIGHLIGHT}Configuring additional directory permissions...${NC}"
chmod o-w /var/crash
chmod o-w /var/tmp
echo -e "${HIGHLIGHT}Configuring firewall...${NC}"
ufw status verbose
ufw deny from 192.168.0.1 to any app OpenSSH
ufw allow from 192.168.0.0/24 to any app OpenSSH
ufw allow from 127.0.0.1
ufw logging on
ufw enable





post1

echo 'Acquire::http { Proxy "http://192.168.0.184:3142"; };' | sudo tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
sudo apt update
sudo apt -y full-upgrade
sudo apt install -y deborphan
sudo apt remove -y popularity-contest unattended-upgrades
sudo -i

upd

sudo apt update
sudo apt upgrade -y
if [ -f /var/run/reboot-required ]; then
sudo shutdown -r now
fi

updone

sudo apt -y --purge autoremove
sudo deborphan -n --find-config | xargs sudo apt -y --purge autoremove
sudo apt -y autoclean
sudo apt -y clean



      dhcp4: no
       addresses: [192.168.0.184/24]
       gateway4: 192.168.0.1
       nameservers:
        addresses: [8.8.8.8,8.8.4.4]
       optional: true


%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\gparted-live-0.32.0-1-i686.iso"
%VB% startvm "%VM%"

zerofree -v /dev/mapper/

# Finish VM

DIR "%BF%\%VM%"
%VB% modifyhd --compact "%BF%\%VM%\%VM%.vdi"
DIR "%BF%\%VM%"

echo 'Acquire::http { Proxy "http://192.168.0.84:3142"; };' | sudo tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
sudo apt update
sudo apt -y full-upgrade
sudo apt install -y deborphan
sudo apt remove -y popularity-contest unattended-upgrades


cd
ln -s /home/joel/common/upd upd
ln -s /home/joel/common/updone updone

cd ~/server
ln -s /home/joel/common/post1 post1
ln -s /home/joel/common/server1 server1
ln -s /home/joel/common/upd upd
ln -s /home/joel/common/updone updone

cd ~/vbox
vi vbga-preinstall
i
sudo apt install -y linux-headers-$(uname -r) build-essential dkms
cat > vbox << FOOD
cd \/media\/\${USER}\/VB*
sudo ./VBoxLinuxAdditions.run
sudo shutdown -r now
FOOD
sudo shutdown -r now
:x

ln -s /home/joel/desktop/desktop2 desktop2
ln -s /home/joel/common/post1 post1
ln -s /home/joel/common/server1 server1
ln -s /home/joel/common/upd upd
ln -s /home/joel/common/updone updone



