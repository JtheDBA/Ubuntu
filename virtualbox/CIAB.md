# Cloud in a Box

[ciab-remote-desktop](https://github.com/bmullan/ciab-remote-desktop) - Brian Mullins's Cloud in a Box (CIAB) Remote Desktop System]

**Update: 9/1/2019 8:59:28 PM - the most recent version was released so I'll probably overhaul this instead of cleaning it up**

## Clone the Base Ubuntu Server

````
SET VM=CIAB Lab
SET VG=Ubuntu Servers
SET BF=%VDID%\%VG%
%VB% clonevm "Ubuntu Server 18.04" --snapshot "BASE1804_01" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
%VB% modifyvm "%VM%" --memory 6144
FOR %A IN (1 2) DO %VB% createhd --filename "%BF%\%VM%\UBU1804_SATA%A.vdi" --size 12000%A
FOR %A IN (1 2) DO %VB% storageattach "%VM%" --storagectl "SATA" --port %A --type hdd --medium "%BF%\%VM%\UBU1804_SATA%A.vdi" --mtype normal
%VB% startvm "%VM%"
```

```
sudo apt install unzip
wget 
sudo unzip -o/opt master.zip 
sudo mv ciab blah blah blah ciab
sudo chmod 755 -R ciab
sudo vi /opt/ciab/setup-containers.sh
```

Even though the script has a "variable" for the installation directory it is hard-coded in all scripts. I also found I had to modify the lxc launch to pull from the ubuntu: images instead of from image: and this was accomplished by modifying setup-containers.sh

I also pushed my apt-cacher-ng proxy to the base cn1 container to use the local apt cache. 

```
lxc launch ubuntu:18.04/amd64 cn1
...
lxc exec cn1 -- /bin/bash -c "rm /etc/apt/sources.list"
lxc file push /opt/ciab/sources.list cn1/etc/apt/
lxc file push /etc/apt/apt.conf.d/01apt-cacher-ng-proxy cn1/etc/apt/apt.conf.d/
sleep 4
```

cd /opt/ciab
./setup-ciab.sh
./setup-containers.sh



"C:\Program Files (x86)\PuTTY\putty.exe" joel@192.168.0.



+-----------+---------+---------------------+------+------------+-----------+
|   NAME    |  STATE  |        IPV4         | IPV6 |    TYPE    | SNAPSHOTS |
+-----------+---------+---------------------+------+------------+-----------+
| ciab-guac | RUNNING | 10.80.74.104 (eth0) |      | PERSISTENT | 0         |
+-----------+---------+---------------------+------+------------+-----------+
| cn1       | RUNNING | 10.80.74.70 (eth0)  |      | PERSISTENT | 0         |
+-----------+---------+---------------------+------+------------+-----------+




