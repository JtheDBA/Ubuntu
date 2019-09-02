# Docker

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

## Clone the Base Ubuntu Server

```DOS .bat
SET VM=Ubuntu Docker BASE
SET VG=Server Templates
SET BF=%VDID%\%VG%
%VB% clonevm "Ubuntu Server 18.04" --snapshot "BASE1804_01" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
%VB% modifyvm "%VM%" --memory 6144
%VB% modifyvm "%VM%" --nic2 bridged --cableconnected2 on --nictype2 virtio --bridgeadapter2 "%VNIC%" --nicpromisc2 allow-all
FOR %A IN (1 2) DO %VB% createhd --filename "%BF%\%VM%\UBU1804_SATA%A.vdi" --size 12000%A
FOR %A IN (1 2) DO %VB% storageattach "%VM%" --storagectl "SATA" --port %A --type hdd --medium "%BF%\%VM%\UBU1804_SATA%A.vdi" --mtype normal
%VB% startvm "%VM%"
```

## Prepare Docker Base

"C:\Program Files (x86)\PuTTY\putty.exe" joel@192.168.0.11

```Bash
ip a

sudo /root/updHost ubudock
sudo vi /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).

network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [192.168.0.208/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [64.233.222.2, 64.233.222.7]
      optional: false
    enp0s8:
      dhcp4: no
      addresses: [192.168.0.209/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [64.233.222.2, 64.233.222.7]
      optional: false
:x

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://download.docker.com/linux/ubuntu bionic stable"
. upd
```

```Bash
. updone
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
sudo shutdown -h 1; exit
```

Take a snapshot for the next steps

```
%VB% snapshot "%VM%" take "BASE" --description "Base for linked clones"
%VB% showvminfo "%VM%"
```

## Clone Multiple Docker VMs from Base

Create a VM for each type of backing filesystem that might be used: the default (i.e. EXT4 volume), LVM extension of the default (i.e. use LVM for the /var/lib/docker mount), BTRFS and ZFS. Each have their pros and cons.

```
SET VG=Ubuntu Docker Lab
SET BF=%VDID%\%VG%
FOR %A IN (default BTRFS ZFS) DO %VB% clonevm "Ubuntu Docker BASE" --snapshot "BASE" --options link --name "Ubuntu Docker %A" --basefolder "%VDID%" --register
FOR %A IN (default BTRFS ZFS) DO %VB% modifyvm "Ubuntu Docker %A" --groups "/%VG%"
```

## Choose Your Storage Driver

[Docker supports the following storage drivers](https://docs.docker.com/storage/storagedriver/select-storage-driver/):

-  overlay2 is the preferred storage driver, for all currently supported Linux distributions, and requires no extra configuration.
-  The btrfs and zfs storage drivers are used if they are the backing filesystem (the filesystem of the host on which Docker is installed). These filesystems allow for advanced options, such as creating "snapshots", but require more maintenance and setup. Each of these relies on the backing filesystem being configured correctly.

### Overlay2

Provide a separate ext4 disk volume for Docker.

```
sudo -i
systemctl stop docker
cp -au /var/lib/docker /var/lib/docker.bk
rm -rf /var/lib/docker/*
fdisk /dev/sdb
n
p
(default)
(default)
(default)
w
mkfs.ext4 /dev/sdb1
vi /etc/fstab
UUID=2f3b7b28-b180-4dfc-96cc-b7f6df7c4791 /var/lib/docker ext4 defaults 0 2
:x
mount /var/lib/docker
cp -au /var/lib/docker.bk/* /var/lib/docker/
cat > /etc/docker/daemon.json << FOOD
{
  "storage-driver": "overlay2"
}
FOOD
systemctl start docker
```

### [ZFS](https://docs.docker.com/storage/storagedriver/zfs-driver/)

The ZFS on Linux (ZoL) port is healthy and maturing. However, at this point in time it is not recommended to use the zfs Docker storage driver for production use unless you have substantial experience with ZFS on Linux.

Prerequisites

-  ZFS is only supported on Docker Engine - Community with Ubuntu 14.04 or higher, with the zfs package (16.04 and higher) or zfs-native and ubuntu-zfs packages (14.04) installed.
-  ZFS is not supported on Docker EE or CS-Engine, or any other Linux platforms.
-  The /var/lib/docker/ directory must be mounted on a ZFS-formatted filesystem.

```Bash
sudo apt-get install zfsutils-linux
sudo reboot
sudo -i
systemctl stop docker
cp -au /var/lib/docker /var/lib/docker.bk
rm -rf /var/lib/docker/*
zpool create -f zpool-docker -m /var/lib/docker /dev/sdb /dev/sdc
cp -au /var/lib/docker.bk/* /var/lib/docker/
cat > /etc/docker/daemon.json << FOOD
{
  "storage-driver": "zfs"
}
FOOD
systemctl start docker
```

### [BTRFS](https://docs.docker.com/storage/storagedriver/btrfs-driver/)

**Note: The btrfs storage driver is only supported on Docker Engine - Community on Ubuntu or Debian, and Docker EE / CS Engine on SLES.**

```Bash
sudo -i
systemctl stop docker
cp -au /var/lib/docker /var/lib/docker.bk
rm -rf /var/lib/docker/*
mkfs.btrfs -m raid1 -d raid1 -f /dev/sdb /dev/sdc
vi /etc/fstab
UUID=7729e6f5-c0da-48ad-87b7-8fe3362cd4c7 /var/lib/docker btrfs defaults 0 2
:x
mount /var/lib/docker
cp -au /var/lib/docker.bk/* /var/lib/docker/
cat > /etc/docker/daemon.json << FOOD
{
  "storage-driver": "btrfs"
}
FOOD
systemctl start docker
```

## Testing

```
docker run hello-world
docker image ls
```

Note: I had to rerun the hello-world sometimes due to name resolution failure when docker attempted to load a remote image. I simply retried and eventually it works. If you know why - please share!

## Networking

TODO

```
docker network create -d macvlan \
  --subnet=172.16.86.0/24 \
  --gateway=172.16.86.1 \
  -o parent=eth0 pub_net
```

# References

-  [https://netplan.io/reference]
-  [https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04]
