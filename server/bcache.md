# BCache

A block layer cache (bcache). say you’ve got a big slow raid 6, and an ssd or three. Wouldn’t it be nice if you could use them as cache… Hence bcache.

Status: work in progress

References

-  [Ubuntu Wiki](https://wiki.ubuntu.com/ServerTeam/Bcache)
-  [kernel.org](https://www.kernel.org/doc/html/latest/admin-guide/bcache.html)
-  [Evil Pie Pirate](https://bcache.evilpiepirate.org)
-  [Arch Wiki](https://wiki.archlinux.org/title/Bcache)
-  [SO](https://stackoverflow.com/questions/22820492/how-to-revert-bcache-device-to-regular-device)

## Thoughts

-  backing disks on iSCSI
-  Chia mad plots

The block size should match the backing devices sector size which will usually be either 512 or 4k. The bucket size should match the erase block size of the caching device with the intent of reducing write amplification. For example, using a HDD with 4k sectors and an SSD with an erase block size of 2MB this command would look like: `make-bcache --block 4k --bucket 2M -C /dev/sdy2`

## Test

To test I cloned a preexisting Hyper-V VM adding six 120GB disks using a PowerShell function I wrote:

``` PowerShell
@('BCache') | Clone-LinuxVM -ParentVHDtag 'UBU2004M_2108' -VMNamePrefix 'SnapRAID Lab' -MemoryStartupBytes 4GB -DataDisks @(120GB, 120GB, 120GB, 120GB, 120GB, 32GB, 32GB, 32GB) -UseDifferencingDisks -Verbose
```

The virtual machine created above assigned devices `sdd sde sdf sdg sdh` as the backing devices i.e. the HDDs and `sdi sdj sdk` as the cache disks i.e. the SSDs.

I started the VM, used `sudo mkdir -p /srv/{u01,u02,u03,u04,u05,u06}` to create mount points, shut down the VM and took a checkpoint.

The [Arch Wiki](https://wiki.archlinux.org/title/Bcache) has five excellent scenarios for setting up bcached btrfs file systems and great information for management.

### BCache

``` bash
sudo -i
dd if=/dev/zero if=/dev/sdd bs=512 count=8
dd if=/dev/zero if=/dev/sdk bs=512 count=8
wipefs -a /dev/sdd
wipefs -a /dev/sdk
make-bcache -B /dev/sdd -C /dev/sdk
mkfs.ext4 /dev/bcache0
blkid /dev/bcache0 | sed -e "s/.dev.bcache.: UUID=\"/UUID=/;s/\" TYPE=\"/  \/srv\/u01  /;s/\".*$/  noatime  0  2/" >> /etc/fstab
reboot
```

### BCache and SnapRAID

- `sdi` - cache disk
- `sdd sde sdf sdg` backing devices SnapRAID data
- `sdh` SnapRAID parity

``` bash
for D in sdd sde sdf sdg sdi
do
wipefs -a /dev/${D}
done
make-bcache -B /dev/sdd -B /dev/sde -B /dev/sdf -B /dev/sdg -C /dev/sdi  --discard
for D in bcache0 bcache1 bcache2 bcache3
do
mkfs.ext4 /dev/${D}
blkid /dev/${D} | sed -e "s/.dev.bcache.: UUID=\"/UUID=/;s/\" TYPE=\"/  \/srv\/u01  /;s/\".*$/  noatime  0  2/" >> /etc/fstab
echo writethrough > /sys/block/${D}/bcache/cache_mode
cat /sys/block/${D}/bcache/cache_mode
done
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
```

## Chia

### Chia Plotting

This assumes MadMax plotter, which threads 75% of I/O to a 112 GB drive, preferably a RAM drive. For those that do not have 128 GB use `bcache` with RAM as the cache disk with 64 or 32 GB to absorb reads and writes to a SSD or hard disk for performance.

I have 32 GB non-ECC so I cannot provide any notes or success stories other than the below works.

I cannot find the original reddit post or anything else but credit to the original post whomever you are.

Using `sudo -i` before each, first prepare the temp1 disk:

``` Bash
wipefs -a /dev/sdh
parted -s -a optimal /dev/sdh mklabel gpt mkpart primary xfs 0% 100% align-check optimal 1
mount /dev/sdh1 /srv/u01
mkdir -p /srv/u01/chia/temp
chown joel:joel -R /srv/u01/chia
chmod 775 /srv/u01/chia
```

Prepare the backing device `/dev/sdc`, create a 20480000 KB `/dev/ram0`, make bcache, register device, set sequential cutoff for Chia plotting, make and mount file systems and create a temp folder:

``` Bash
wipefs -a /dev/sdc
modprobe brd rd_nr=1 rd_size=20480000 max_part=0
make-bcache -B /dev/sdc -C /dev/ram0 --writeback
echo /dev/ram0 > /sys/fs/bcache/register
echo 0 > /sys/block/bcache0/bcache/sequential_cutoff
cat /sys/block/bcache0/bcache/state
mkfs.xfs /dev/bcache0
mount /dev/sdh1 /srv/u01
mount /dev/bcache0 /srv/u02
mkdir -p /srv/u02/chia/temp
chown joel:joel -R /srv/u02/chia
chmod 775 /srv/u02/chia
```

dismount `/dev/bcache0`, unregister, stop, flush, wipe file systems of `/dev/ram0` and the backing device, remove brd module:

``` Bash
umount -v /dev/bcache0
echo 1 > `bcache-super-show -f /dev/ram0 | sed -e '/cset.uuid/!d;s/cset.uuid[[:blank:]]*/\/sys\/fs\/bcache\//;s/$/\/unregister/'`
echo 1 >/sys/block/bcache0/bcache/stop
blockdev --flushbufs /dev/ram0
wipefs -a /dev/ram0
wipefs -a /dev/sdc
rmmod brd
```
