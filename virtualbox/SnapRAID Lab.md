# SnapRAID Lab

**WORK IN PROGRESS**

References

- [Setting up SnapRAID on Ubuntu to Create a Flexible Home Media Fileserver](https://zackreed.me/setting-up-snapraid-on-ubuntu/)
- [SnapRAID](https://github.com/amadvance/snapraid) - Andrea Mazzoleni's backup program for disk arrays

# Create VM

```DOS .bat
SET VM=Ubuntu SnapRAID
SET VG=Ubuntu Servers
SET BF=%VDID%\%VG%
%VB% clonevm "Ubuntu Server 18.04" --snapshot "BASE1804_1A" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
FOR %A IN (1 2 3 4 5) DO %VB% createhd --filename "%BF%\%VM%\UBU1804_DATA%A.vdi" --size 9000
FOR %A IN (1 2 3 4 5) DO %VB% storageattach "%VM%" --storagectl "SATA" --port %A --type hdd --medium "%BF%\%VM%\UBU1804_DATA%A.vdi" --mtype normal

```
I find it easier to SSH in and copy/paste so ... `"C:\Program Files (x86)\PuTTY\putty.exe" sadmin@192.168.0.?`

# Installing

```Bash
sudo -i
apt install -y parted gdisk gcc git make
cd
wget https://github.com/amadvance/snapraid/releases/download/v11.3/snapraid-11.3.tar.gz
tar xzvf snapraid-11.3.tar.gz
cd snapraid-11.3/
./configure
make
make check
make install
cd ..
cp ~/snapraid-11.3/snapraid.conf.example /etc/snapraid.conf
cd ..
rm -rf snapraid*
mkdir -p /mnt/data/{sdb,sdc,sdd,sde}
mkdir -p /mnt/parity/sdf
cat >> /etc/fstab << FOOD

# SnapRAID Disks
FOOD
parted -a optimal /dev/sdf
  mklabel gpt
  mkpart primary 0% 100%
  align-check
  optimal
  1
  quit
sgdisk --backup=table /dev/sdf
for FOO in sdb sdc sdd sde
do
sgdisk --load-backup=table /dev/${FOO}
mkfs.ext4 -m 2 -T largefile4 /dev/${FOO}1
UUID=c220a84e-a9a4-45a0-947d-c05ed2d84b35 /mnt/${FOO} ext4 defaults 0 2 >> /etc/fstab
done
mkfs.ext4 -m 0 -T largefile4 /dev/sdf1
cat >> /etc/fstab << FOOD

# SnapRAID Parity Disks

FOOD
UUID=c220a84e-a9a4-45a0-947d-c05ed2d84b35 /mnt/${FOO} ext4 defaults 0 2 >> /etc/fstab

```


GNU Parted 2.3
Using /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt
(parted) mkpart primary 0% 100%
(parted) align-check
alignment type(min/opt)  [optimal]/minimal? optimal
Partition number? 1
1 aligned
(parted) quit


1
2
mkdir -p /mnt/data/{disk1,disk2,disk3,disk4}
mkdir -p /mnt/parity/1-parity

1
mkfs.ext4 -m 2 -T largefile4 /dev/sdc1
mkfs.ext4 -m 2 -T largefile4 /dev/sdd1
mkfs.ext4 -m 2 -T largefile4 /dev/sde1

Put a filesystem on the parity disk (here I’m reserving 0%, or letting it use the whole disk for parity).



ls -la /dev/disk/by-id/ | grep part1  | cut -d " " -f 11-20
1
ls -la /dev/disk/by-id/ | grep part1  | cut -d " " -f 11-20
It should give you output like this.


ata-HGST_HDN724040ALE640_PK2334PBHDYY0R-part1 -> ../../sdb1
ata-HGST_HDS5C4040ALE630_PL2331LAG90YYJ-part1 -> ../../sdc1
ata-HGST_HUS726060ALA640_AR31001EG1YE8C-part1 -> ../../sde1
ata-Hitachi_HDS5C3030ALA630_MJ0351YNYYYK9A-part1 -> ../../sdf1
ata-Hitachi_HDS5C3030ALA630_MJ1313YNGYYYJC-part1 -> ../../sdg1
1
2
3
4
5
ata-HGST_HDN724040ALE640_PK2334PBHDYY0R-part1 -> ../../sdb1
ata-HGST_HDS5C4040ALE630_PL2331LAG90YYJ-part1 -> ../../sdc1
ata-HGST_HUS726060ALA640_AR31001EG1YE8C-part1 -> ../../sde1
ata-Hitachi_HDS5C3030ALA630_MJ0351YNYYYK9A-part1 -> ../../sdf1
ata-Hitachi_HDS5C3030ALA630_MJ1313YNGYYYJC-part1 -> ../../sdg1
You use the above to add them to /etc/fstab

# SnapRAID Disks
/dev/disk/by-id/ata-VBOX_HARDDISK_VB205c385c-35155d82-part1 /mnt/data/disk1 ext4 defaults 0 2
/dev/disk/by-id/ata-VBOX_HARDDISK_VB6ccade4c-99cd3f89-part1 /mnt/data/disk2 ext4 defaults 0 2
/dev/disk/by-id/ata-VBOX_HARDDISK_VB8d191fe8-542dee6c-part1 /mnt/data/disk3 ext4 defaults 0 2
# SnapRAID Parity Disks
/dev/disk/by-id/ata-VBOX_HARDDISK_VB7f980c87-b814ac45-part1 /mnt/parity/1-parity ext4 defaults 0 2



nano /etc/fstab
1
nano /etc/fstab
It should look something like this.


# SnapRAID Disks
/dev/disk/by-id/ata-HGST_HDN724040ALE640_PK2334PBHDYY0R-part1 /mnt/data/disk1 ext4 defaults 0 2
/dev/disk/by-id/ata-HGST_HDS5C4040ALE630_PL2331LAG90YYJ-part1 /mnt/data/disk2 ext4 defaults 0 2
/dev/disk/by-id/ata-HGST_HUS726060ALA640_AR31001EG1YE8C-part1 /mnt/data/disk3 ext4 defaults 0 2
/dev/disk/by-id/ata-Hitachi_HDS5C3030ALA630_MJ0351YNYYYK9A-part1 /mnt/data/disk4 ext4 defaults 0 2


/dev/disk/by-id/ata-Hitachi_HDS5C3030ALA630_MJ1313YNGYYYJC-part1 /mnt/parity/1-parity ext4 defaults 0 2
1
2
3
4
5
6
7
8
# SnapRAID Disks
/dev/disk/by-id/ata-HGST_HDN724040ALE640_PK2334PBHDYY0R-part1 /mnt/data/disk1 ext4 defaults 0 2
/dev/disk/by-id/ata-HGST_HDS5C4040ALE630_PL2331LAG90YYJ-part1 /mnt/data/disk2 ext4 defaults 0 2
/dev/disk/by-id/ata-HGST_HUS726060ALA640_AR31001EG1YE8C-part1 /mnt/data/disk3 ext4 defaults 0 2
/dev/disk/by-id/ata-Hitachi_HDS5C3030ALA630_MJ0351YNYYYK9A-part1 /mnt/data/disk4 ext4 defaults 0 2
 
# Parity Disks
/dev/disk/by-id/ata-Hitachi_HDS5C3030ALA630_MJ1313YNGYYYJC-part1 /mnt/parity/1-parity ext4 defaults 0 2
As you may be able to see, the above shows the type of connection, in this case SATA, the Manufacturer of the disk, the part number of the disk, the serial number of the disk, and the partition we are using from the disk.  This makes indentying disks in the event of a failure super easy.

Mount the disks after you add them to /etc/fstab


mount -a
1
mount -a
Next, you’ll want to configure SnapRAID.


nano /etc/snapraid.conf
1
nano /etc/snapraid.conf
This is how I configured mine


parity /mnt/parity/1-parity/snapraid.parity

content /var/snapraid/content
content /mnt/data/disk1/content
content /mnt/data/disk2/content
content /mnt/data/disk3/content

disk d1 /mnt/data/disk1/
disk d2 /mnt/data/disk2/
disk d3 /mnt/data/disk3/

exclude *.bak
exclude *.unrecoverable
exclude /tmp/
exclude /lost+found/
exclude .AppleDouble
exclude ._AppleDouble
exclude .DS_Store
exclude .Thumbs.db
exclude .fseventsd
exclude .Spotlight-V100
exclude .TemporaryItems
exclude .Trashes
exclude .AppleDB

block_size 256




mkdir -p /var/snapraid/
1
mkdir -p /var/snapraid/
Once that’s complete, you should sync your array.


snapraid sync
1
snapraid sync
Since moving to SnapRAID 7.x, the above mentioned script no longer works. I have revised the script to accommodate dual parity, and to integrate the changes in the counters.

Finally, I wanted something to pool these disks together. There are four options here (choose your own adventure). The nice part about any of these is that it’s very easy to change later if you run into something you don’t like.

1. The first option is mhddfs. It is super easy to setup and “just works”, but many people have run into random disconnects while writing to the pool (large rsync jobs where causing this for me). I have since updated my mhddfs tutorial with some new FUSE options that seems to remedy the disconnect issue. mhddfs runs via FUSE vs. a kernel driver for AUFS, so it’s not as fast as AUFS and it does have more system overhead.

2. The second option is to use AUFS instead. The version bundled with Ubuntu has some weirdness with deletion and file moves with both it’s opaque and whiteout files. It also does not support exporting via NFS.

3. The third option is to use AUFS, but to compile your own versions to support the hnotify option and allow for export via NFS. This is where I landed for a few years after trying both of the above for many months/years.

4. This is what I use Finally, a solution that performs well and is easy to use. MergerFS (the solution I’m currently using). This is a FUSE based solution, but it’s fast and has create modes like AUFS. It’s also easy to install and requires no compiling unlike AUFS to get it working. This is what I use now, and it’s great and actively developed.

After choosing one of the options above, you should now have a mount point at /storage that is pooling all of your disks into one large volume. You’ll still want to setup a UPS and SMART monitoring for your disks. Another thing I did was write up a simple BASH script to watch my disk usage, and email me if a disk gets over 90% used, so I can add another disk to the array.

Next, I would strongly suggest you read my other articles to setup email for monitoring, SMART information monitoring , spinning down disks, setting up a UPS battery backup, and other raid array actions. Being able to cope with drives failing useful, but it’s nice to know that one has failed and be able to replace it too.

Updating in the future
You may wonder…”Hmm, I installed this fancy SnapRAID a while back, but the shiny new version of SnapRAID just came out, so how do I update?” The nice thing about SnapRAID is that it’s a standalone binary with no dependencies, so you can upgrade it in place. Just grab the latest version, untar, and install.


wget https://github.com/amadvance/snapraid/releases/download/v11.2/snapraid-11.2.tar.gz
tar xzvf snapraid-11.2.tar.gz
cd snapraid-11.2/
./configure
make
make check
make install
1
2
3
4
5
6
7
wget https://github.com/amadvance/snapraid/releases/download/v11.2/snapraid-11.2.tar.gz
tar xzvf snapraid-11.2.tar.gz
cd snapraid-11.2/
./configure
make
make check
make install
You can check your version like this.


snapraid -V
1
snapraid -V
Other Items:
If you would like to have encrypted SnapRAID disks, the following will go through that.

Tags: Popular

Zack
Zack
I love learning new things and trying out the latest technology.

YOU MAY ALSO LIKE...

 Send system email with Gmail and sSMTP
0
Send system email with Gmail and sSMTP

NOVEMBER 15, 2011
 Home Setup Changes
0
Home Setup Changes

JULY 23, 2015
 Software RAID 5 in Ubuntu/Debian with mdadm
2
Software RAID 5 in Ubuntu/Debian with mdadm

NOVEMBER 15, 2011
61 RESPONSES

Comments61
Pingbacks0
DaveDave  September 8, 2016 at 10:01 am
Awesome been looking for someone todo a more current SNAPRAID follow up. Thanks!!!

Log in to Reply
ZackZack  September 8, 2016 at 12:59 pm
I’m glad you found this helpful Dave. I just migrated this content from my old site, though, so this has been an article I have updated for a couple of years now. Please let me know if you have any questions.

Log in to Reply
Joe  September 17, 2016 at 11:54 am
your first set of commands didn’t migrate over well;

this
apt-get update && apt-get dist-upgrade -y && reboot

should be
apt-get update && apt-get dist-upgrade -y && reboot

Log in to Reply
ZackZack  September 17, 2016 at 11:43 pm
Thanks! The stupid save reverted them back to & I just corrected the issue.

Log in to Reply
Joe  September 17, 2016 at 11:55 am
ack it looks like my amp; amp; didn’t get written correctly in my post.

Log in to Reply
oxzhor  November 16, 2016 at 3:16 pm
Hi Zack,

Great post! normally i work with CentOS but you done nice work on Ubuntu 16.x.
I buy a old Dell R510 and put a perc H310 into it and will follow your post to setup a backupserver.
I keep you updated over how the project will go :).

Keep the good work up
----------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo -i
apt-get -y update && apt-get -y install git make build-essential g++ debhelper python automake libtool lsb-release
git clone https://github.com/trapexit/mergerfs.git
cd mergerfs
make install-build-pkgs
make deb
dpkg -i mergerfs*_amd64.deb





wget https://github.com/amadvance/snapraid/releases/download/v11.2/snapraid-11.2.tar.gz
tar xf snapraid-*.tar.gz
cd snapraid-11.2/
