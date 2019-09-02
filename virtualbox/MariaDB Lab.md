# Maria DB Lab

## Objectives

Through everything available through the Community i.e. non Enterprise versions of software:

-  MariaDB Server
   -  Installation and Storage Engines
   -  SQL
   -  Programming
   -  Basic User and Server Security
   -  Backup and Restore
   -  High Availability Replication
   -  High Availability Galera Clustering
-  MariaDB Columnstore
-  MariaDB MaxScale 

# Create BASE VM

Clone existing minimal base.

```DOS .bat
SET VM=Maria DB BASE
SET VG=Maria DB Lab
SET BF=%VDID%\%VG%
%VB% clonevm "Ubuntu Server 18.04" --snapshot "BASE1804_01" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
%VB% createhd --filename "%BF%\%VM%\MariaDB.vdi" --size 100000
%VB% storageattach "%VM%" --storagectl "SATA" --port 1 --type hdd --medium "%BF%\%VM%\MariaDB.vdi" --mtype normal
```

`"C:\Program Files (x86)\PuTTY\putty.exe" joel@192.168.0.`

```Bash
sudo -i
fdisk
mkfs.ext4 -m 2 -T largefile4 /dev/sdb1


cat >> /etc/sysctl.conf << FOOD
# MariaDB - https://mariadb.com/kb/en/library/configuring-swappiness/
vm.swappiness = 1
#
FOOD
cat >> /etc/security/limits.conf << FOOD
# MariaDB - https://mariadb.com/kb/en/library/configuring-linux-for-mariadb/
mysql soft nofile 65535
mysql hard nofile 65535
mysql soft core unlimited
mysql hard core unlimited
#

shutdown -h 1; exit
FOOD
```

```DOS .bat
%VB% snapshot "%VM%" take "BASE01" --description "Snapshot of MariaDB Base VM"
SET VM=MariaDB_Standalone
SET VG=Maria DB Lab
SET BF=%VDID%\%VG%
%VB% clonevm "Maria DB BASE" --snapshot "BASE01" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
%VB% createhd --filename "%BF%\%VM%\MariaDB.vdi" --size 100000
%VB% storageattach "%VM%" --storagectl "SATA" --port 1 --type hdd --medium "%BF%\%VM%\MariaDB.vdi" --mtype normal
```


sudo apt-get install mariadb-server 
 galera-4 mariadb-common
 mariadb-client
 libmariadb3 mariadb-backup

sudo apt-get install mariadb-server mariadb-client mariadb-backup

/var/lib/mysql

├── aria_log.00000001
├── aria_log_control
├── debian-10.4.flag
├── ib_buffer_pool
├── ibdata1
├── ib_logfile0
├── ib_logfile1
├── ibtmp1
├── multi-master.info
