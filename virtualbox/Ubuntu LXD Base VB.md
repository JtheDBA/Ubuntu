# Ubuntu LXD Base VB

## Clone Mini VM

```
SET VM=LXD BASE
SET VG=Ubuntu LXD Lab
SET BF=%VDID%\%VG%
%VB% clonevm "UBU1804MINI" --snapshot "BASE" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
%VB% modifyvm "%VM%" --memory 8192 --boot1 disk --boot2 none
%VB% createmedium --filename "%BF%\%VM%\LXDBASE_SRV" --size 80001
%VB% createmedium --filename "%BF%\%VM%\LXDBASE_LXD" --size 200002
%VB% storageattach "%VM%" --storagectl "SATA" --port 1 --type hdd --medium "%BF%\%VM%\LXDBASE_SRV.vdi" --mtype normal
%VB% storageattach "%VM%" --storagectl "SATA" --port 2 --type hdd --medium "%BF%\%VM%\LXDBASE_LXD.vdi" --mtype normal
%VB% startvm "%VM%"
```

## Configure Step 1 - Format and mount "server" disk, install LXD packages and reboot

```shell
. upd
sudo -i
hostnamectl set-hostname UBULXD-BASE
sed -i -e 's/UBU18042/UBULXD-BASE/' /etc/hosts
fdisk /dev/sdb
mkfs.ext4 /dev/sdb1
mkdir /srv/{local,remote}
vi /etc/fstab
# srv
UUID=see-mkfs.ext-above /srv/local ext4 defaults 0 2
:x
mount /srv/local
apt install -y snapd btrfs-tools
shutdown -r 1; exit
exit
```

## Configure Step 2 - Init LXD, configure VM for LXD, reboot

```shell
sudo -i
snap install lxd
lxd init --auto --storage-backend btrfs --storage-create-device /dev/sdc
cat >> /etc/sysctl.conf << FOOD
fs.inotify.max_queued_events = 1048576
fs.inotify.max_user_instances = 1048576
fs.inotify.max_user_watches = 1048576
FOOD
cat >> /etc/security/limits.conf << FOOD
* soft nofile 100000
* hard nofile 100000
FOOD
shutdown -r 5; exit
exit
```

## Configure Step 3 - Configure lxc network, profiles, create base container and snapshot

```shell
lxc network create lxdbr1 ipv4.nat=false ipv6.nat=false
lxc profile copy default lxrpr0
lxc profile copy default lxrpr1
lxc profile copy default lxrpr2
lxc init ubuntu:18.04 ubu1804
lxc file push /etc/apt/apt.conf.d/01apt-cacher-ng-proxy ubu1804/etc/apt/apt.conf.d/01apt-cacher-ng-proxy
lxc file push /home/${USER}/upd ubu1804/root/upd
lxc file push /home/${USER}/updone ubu1804/root/updone
lxc start ubu1804
lxc exec ubu1804 bash
. upd
. updone
exit
lxc stop ubu1804
lxc snapshot ubu1804 ubu1804c0
sudo shutdown -h 1; exit
```

## Snapshot VM

```
%VB% snapshot "%VM%" take "BASE" --description "Create BASE Snapshot for Linked Clones"
```

If you backup your virtual machines that would be a good time to do so.