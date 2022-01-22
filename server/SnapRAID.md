# SnapRAID

[SnapRAID](http://www.snapraid.it) is a backup program for disk arrays. It stores parity information of your data and it recovers from up to six disk failures. SnapRAID is mainly targeted for a home media center, with a lot of big files that rarely change. *Or Chia plots.*

Status: work in progress

References



## Installation

*The SnapRAID repository rarely gets updated so I build from source when I have a virtual machine I will use as a template.*

Installation steps: (https://www.havetheknowhow.com/Configure-the-server/Install-SnapRAID.html)

``` bash
sudo apt-get install gcc make
sudo mkdir /var/lib/snapraid
sudo chmod a+w /var/lib/snapraid
cd /var/lib/snapraid
wget https://github.com/amadvance/snapraid/releases/download/v11.6/snapraid-11.6.tar.gz
tar -xzf snapraid-11.6.tar.gz
rm *.gz
cd snapraid-11.6
./configure
make
make check
sudo make install
cd
rm -R /var/lib/snapraid
```

The `./configure` step should run through without issue and the last few lines should read... 

```
configure: creating ./config.status
config.status: creating Makefile
config.status: creating config.h
```

The `make check` step will run through a whole bunch of tests and, hopefully, come back with the following:

```
Everything OK
===== Regression test completed with SUCCESS!
===== Please ignore any error message printed above, they are expected!
===== Everything OK
make[1]: Leaving directory '/var/lib/snapraid/snapraid-11.6'
```


```
/usr/bin/mkdir -p '/usr/local/bin'
/usr/bin/install -c snapraid '/usr/local/bin'
-rwxr-xr-x 1 root root 2123448 Nov 23 20:55 snapraid*
/usr/bin/mkdir -p '/usr/local/share/man/man1'
/usr/bin/install -c -m 644 snapraid.1 '/usr/local/share/man/man1'
-rw-r--r-- 1 root root 53412 Nov 23 20:55 snapraid.1

```


## Test

To test I cloned a preexisting Hyper-V VM adding six 120GB disks using a power shell script: `@('SnapRAID') | Clone-LinuxVM -ParentVHDtag 'UBU2004M_2108' -VMNamePrefix 'SnapRAID Lab' -MemoryStartupBytes 4GB -DataDisks @(120GB, 120GB, 120GB, 120GB, 120GB, 120GB) -UseDifferencingDisks -Verbose`



-  SnapRAID data and parity devices: sda sdb sdc sdd sde sdf
-  Foo

Note: 5 disks

``` bash
sudo -i
fdisk -l
echo "Prepare storage"
S=0
for D in sda sdb sdc sdd sde sdf
do
((S=$S+1))
U=u0$S
echo "Partition and make filesystem /dev/${D}1 for mount /srv/${U}"
parted -s -a optimal /dev/${D} mklabel gpt mkpart primary ext4 0% 100% align-check optimal 1
sync
mkfs.ext4 -m 0 -T largefile4 /dev/${D}1
blkid /dev/${D}1 | sed -e "s/.dev.sd.1: UUID=\"/UUID=/;s/\" TYPE=\"/  \/srv\/${U}  /;s/\" PART.*$/  noatime  0  2/" >> /etc/fstab
done
# Create folder for a snapraid.content file
btrfs subvolume create /var/snapraid
# Mount 
mkdir /srv/${U}
mount /srv/${U}
cat > /etc/snapraid.conf << FOOD
parity /srv/${U}/snapraid.parity
content /var/snapraid/snapraid.content
content /srv/u01/snapraid.content
content /srv/u02/snapraid.content
FOOD
# Mount data disk, append to config and create some test folders
for U in u01 u02 u03 u04 u05
do
mkdir /srv/${U}
mount /srv/${U}
cat >> /etc/snapraid.conf << FOOD
data ${U} /srv/${U}/
FOOD
cd /srv/${U}
mkdir -p chia/{plots,temp}
chmod 770 -R chia/
chown joel:joel -R chia/
done
snapraid sync
#
exit
```

Create some fake plot files and perform another sync

``` bash
cd /srv/u01/chia/plots
dd if=/dev/urandom bs=1024 count=1024 >1m; cat 1m 1m 1m 1m 1m >5m; cat 5m 5m 5m 5m 5m >25m; cat 25m 25m 25m 25m>d32_u01somedamnlongnumber.plot
cat 25m 25m 25m>/srv/u02/chia/plots/d32_u02somedamnlongnumber.plot
cat 25m 25m 25m 25m 25m>/srv/u03/chia/plots/d32_u03somedamnlongnumber.plot
cat 25m 25m 25m 25m 25m 25m>/srv/u04/chia/plots/d32_u04somedamnlongnumber.plot
cat 25m 25m>/srv/u05/chia/plots/d32_u05somedamnlongnumber.plot
sudo snapraid sync
```

Create more fake plot files and perform another sync

``` bash
cat 25m 25m 25m 25m>d32_u01somedamnlo123u23er.plot
cat 25m 25m 25m 25m>/srv/u03/chia/plots/d32_u03so332312longnumber.plot
sudo snapraid sync
```

I simulated a drive failure on `/dev/sdb` mounted on `/srv/u02` and recovery to a replacement drive `/dev/sde`  using:

``` bash
sudo -i
D=sde
U=u02
parted -s -a optimal /dev/${D} mklabel gpt mkpart primary ext4 0% 100% align-check optimal 1
sync
mkfs.ext4 -m 0 -T largefile4 /dev/${D}1
blkid /dev/${D}1 | sed -e "s/.dev.sd.1: UUID=\"/UUID=/;s/\" TYPE=\"/  \/srv\/${U}  /;s/\" PART.*$/  noatime  0  2/" >> /etc/fstab
vi /etc/fstab
mount /srv/u02

snapraid -d u02 -l fix.log fix`
```
