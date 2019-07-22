# Ubuntu 18.04 Server on HyperV
## Purpose

This virtual machine will act as a centralized location for:

* cached apt packages (apt-cacher-ng)
* software for Ubuntu Linux
* .iso images that can be prepared and updated through zsync and/or bit torrent
* LXD containers for various services

## Primary References

-  (https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v)
-  (https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v)

## Before Creating the VM

Since the purpose of this virtual machine is to live on a physical system containing files and services outside the virtual machine we should perform a few things before continuing:

1.  create a download folder on the host
2.  download the base `ubuntu-18.04-mini-amd64.iso` Ubuntu Mini image and `gparted-live-0.33.0-1-i686.iso` GParted image (for virtual disk optimization)

I created a download shared folder on the host for our home network. This folder will contain all software and disk images. Since this share can be rebuilt I do not include it in any backups on the host. All Windows and Linux physical computers mount this location locally so it can be used as a centralized folder for all software.

## Create VM

```PowerShell
New-VHD -Path 'V:\Virtual Hard Disks\UBU1804.vhdx' -SizeBytes 127GB -Dynamic -BlockSizeBytes 1MB
New-VHD -Path 'V:\Virtual Hard Disks\UBU1804_LXD.vhdx' -SizeBytes 80GB -Dynamic -BlockSizeBytes 1MB
```

- Secure Boot disabled
- Memory
- Using dynamic memory with start of memory at 2 GB, minimum RAM at 1 GB, maximum RAM at 4 GB and defaults for the rest
- Processor
- Two virtual processors with defaults

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
apt install -y linux-azure 
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
       addresses: [192.168.0.84/24]
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

joel@ubu1804:~$ sudo apt install linux-azure
[sudo] password for joel:
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  linux-azure-cloud-tools-4.18.0-1011 linux-azure-headers-4.18.0-1011 linux-azure-tools-4.18.0-1011 linux-cloud-tools-4.18.0-1011-azure linux-cloud-tools-azure linux-headers-4.18.0-1011-azure
  linux-headers-azure linux-image-4.18.0-1011-azure linux-image-azure linux-modules-4.18.0-1011-azure linux-tools-4.18.0-1011-azure linux-tools-azure
Suggested packages:
  fdutils linux-azure-doc-4.18.0 | linux-azure-source-4.18.0 linux-azure-tools
The following NEW packages will be installed:
  linux-azure linux-azure-cloud-tools-4.18.0-1011 linux-azure-headers-4.18.0-1011 linux-azure-tools-4.18.0-1011 linux-cloud-tools-4.18.0-1011-azure linux-cloud-tools-azure linux-headers-4.18.0-1011-azure
  linux-headers-azure linux-image-4.18.0-1011-azure linux-image-azure linux-modules-4.18.0-1011-azure linux-tools-4.18.0-1011-azure linux-tools-azure
0 upgraded, 13 newly installed, 0 to remove and 0 not upgraded.
Need to get 35.6 MB of archives.
After this operation, 169 MB of additional disk space will be used.
Do you want to continue? [Y/n]





.smbcredentials
joel@ubu1804:~$ pwd
/home/joel

.smbcredentials
joel@ubu1804:~$ pwd
/home/joel

//192.168.0.80/Shared /media/local cifs credentials=/root/.smblocalcredentials,iocharset=utf8,sec=ntlm,dir_mode=0777,file_mode=0777,vers=1.0    0   0

# Configure server to use local cache
echo 'Acquire::http { Proxy "http://127.0.0.1:3142"; };' | tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
apt update
test -x /var/cache/apt-cacher-ng/_import || mkdir -p -m 2755 /var/cache/apt-cacher-ng/_import
mv -uf /var/cache/apt/archives/*.deb /var/cache/apt-cacher-ng/_import/
chown -R apt-cacher-ng.apt-cacher-ng /var/cache/apt-cacher-ng/_import
lynx http://127.0.0.1:3142/acng-report.html?doImport=Start+Import#bottom

# This is optional, but load the packages from the .iso images into the apt cache
#
for foo in kubuntu-18.04-desktop-amd64.iso lubuntu-18.04-desktop-amd64.iso ubuntu-18.04-live-server-amd64.iso ubuntu-mate-18.04-desktop-amd64.iso lubuntu-18.04-alternate-amd64.iso ubuntu-18.04-desktop-amd64.iso ubuntu-budgie-18.04-desktop-amd64.iso xubuntu-18.04-desktop-amd64.iso
do
mount -o loop /media/local/Software/ISO/${foo} /var/cache/apt-cacher-ng/_import
lynx http://127.0.0.1:3142/acng-report.html?doImport=Start+Import#bottom
umount /var/cache/apt-cacher-ng/_import
done



mkdir server
vi post1
i
apt remove -y unattended-upgrades
cat > /etc/apt/apt.conf.d/01apt-cacher-ng-proxy << FOOD
Acquire::http { Proxy "http://192.168.0.84:3142"; };
FOOD
apt update
apt install -y cifs-utils libcups2 lynx mc nfs-common p7zip-full p7zip-rar rar samba-common unzip zip tree
shutdown -h now; exit
:x

cat > upd << FOOD
sudo ucaresystem-core
FOOD

vi post2
i
ufw status verbose
ufw deny from 192.168.0.1 to any app OpenSSH
ufw allow from 192.168.0.0/24 to any app OpenSSH
ufw allow from 127.0.0.1
ufw logging on
cat >> /etc/bash.bashrc << FOOD
umask 077
FOOD
cat > /etc/hosts.allow << FOOD
sshd : ALL : ALLOW
ALL: LOCAL, 127.0.0.1
FOOD
cat > /etc/hosts.deny << FOOD
ALL: PARANOID
FOOD
cat > /etc/issue.net << FOOD
***************************************************************************
NOTICE

This computer system is the private property of the Mathias family. It is
for authorized use only.

By using this system, you consent to interception, monitoring, recording,
copying, auditing, inspection, and disclosure of actions performed on
system.  Unauthorized or improper use of this system may result in civil
action. By continuing to use this system you indicate your awareness of and
consent to these terms and conditions of use.

LOG OFF IMMEDIATELY if you do NOT agree to the conditions in this warning.
****************************************************************************
FOOD
chmod 1777 -R /tmp
chown root.root /tmp


echo 'Acquire::http { Proxy "http://192.168.0.84:3142"; };' | sudo tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy


# Network File Shares

# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.0.84/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [192.168.0.1, 64.233.222.2, 64.233.222.7]
      optional: false
    eth1:
      dhcp4: no
      addresses: [192.168.0.96/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [192.168.0.1, 64.233.222.2, 64.233.222.7]
      optional: false




network:
  version: 2
  ethernets:
    enp1s0f0:
      addresses: [10.1.20.24/24]
      gateway4: 10.1.20.1
      nameservers:
        addresses:
        - 10.1.20.254
        - 10.1.20.253
        - 1.1.1.1
        search:
        - paw.blue
    enp1s0f1:
      dhcp4: false
# I don't think this bridge is necessary but I could be wrong


network:
    ethernets:
        eth0:
            addresses: []
            dhcp4: true
            optional: true
    version: 2


network:
    ethernets:
        eth0:
            dhcp4: no
            addresses: [192.168.0.84/24]
            gateway4: 192.168.0.1
            nameservers:
                addresses: [8.8.8.8,8.8.4.4]
            optional: true
    version: 2


     dhcp4: no
     addresses: [192.168.1.222/24]
     gateway4: 192.168.1.1
     nameservers:
       addresses: [8.8.8.8,8.8.4.4]