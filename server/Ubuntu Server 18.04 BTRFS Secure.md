# Secure Ubuntu Server 18.04 BTRFS

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

Note: I found Thomas Sjögren's aka konstruktoid's [hardening](https://github.com/konstruktoid/hardening) repository maybe a month after first starting the revamp of the originally based on LVM document I did for 16.04 and 14.04. It appears Thomas is way more advanced that I and if you need a serious solution maybe go there first?

## Goal

The goal of this document is to create a secure installation of Ubuntu Server using the BTRFS file system. This is an attempt to combine numerous online resources into something that is both reasonable and implementable in a small to midsize virtualized environment.

# Create the Virtual Machine

Two storage devices are created for the virtual machine. The first device is for the BTRFS based operating system and the second for temporary file systems.

The separation of devices was a consideration for environments using a disaster recovery software system (my employer uses Zerto) where the Zerto best practices guide recommends:

*When configuring a VPG, Zerto Virtual Replication provides an option to mark individual volumes as "Temp Data Disk" (formerly known as "Swap"). This functionality is extremely useful when your operating system or database has a dedicated volume for swap, virtual memory, temporary backups, or files that are only relevant to a live and running machine, and are useless following a reboot. When one of the protected VM volumes is marked as a "Temp Data Disk" volume, upon saving the VPG, the volume will undergo an Initial Sync. However, all subsequent IOs to that volume will be ignored. The purpose of the Initial Sync's is to make sure the full remote file system is available in the event of a Failover Test, Live Failover, Move, or Offsite Clone operation.*

This makes sense. You would not want temporary or volatile data being replicated over a leased line to a remote site used for disaster recovery. Plus this also solves `/tmp` mount options and where to put `swap`

## Installation

Assumes VirtualBox on Windows 10 host; obviously alter to your host either physical or virtual

```DOS .bat
SET VM=Ubuntu Server 18.04 BTRFS Secure BASE
SET VG=Server Templates
SET BF=%VDID%\%VG%
%VB% createvm --name "%VM%" --groups "/Server Templates" --ostype Ubuntu_64 --register
%VB% modifyvm "%VM%" --snapshotfolder default --clipboard bidirectional --draganddrop hosttoguest
%VB% modifyvm "%VM%" --memory 2048 --boot2 dvd --boot1 disk --boot3 none --boot4 none --firmware bios --chipset piix3 --acpi on --ioapic on --rtcuseutc on --cpus 2 --cpuhotplug on --cpuexecutioncap 100 --pae on --paravirtprovider kvm --hpet on --hwvirtex on --nestedpaging on
%VB% modifyvm "%VM%" --vram 16 --monitorcount 1 --accelerate3d off --audio none --usb on --usbehci on
%VB% modifyvm "%VM%" --nic1 bridged --cableconnected1 on --nictype1 virtio --bridgeadapter1 "%VNIC%"
%VB% storagectl "%VM%" --name "IDE" --add ide --controller PIIX4 --hostiocache on --bootable on
%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\ubuntu-18.04-mini-amd64.iso"
%VB% storagectl "%VM%" --name "SATA" --add sata --controller IntelAhci --portcount 6 --hostiocache off --bootable on
%VB% createhd --filename "%BF%\%VM%\UBU1804S0.vdi" --size 80000
%VB% createhd --filename "%BF%\%VM%\UBU1804S1.vdi" --size 10000
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%BF%\%VM%\UBU1804S0.vdi" --mtype normal
%VB% storageattach "%VM%" --storagectl "SATA" --port 1 --type hdd --medium "%BF%\%VM%\UBU1804S1.vdi" --mtype normal
%VB% startvm "%VM%"
```

Use the defaults for the installation process with the exception of the following:

-  User Full Name: System Administrator
-  User: sadmin  *get it - "sad" min - ha ha ok sorry should be serious here*
-  Manual Partitioning
   1.  disk 0 - new partition type BTRFS mount `/`
   2.  disk 1 - new partition type LVM physical volume
   3.  Setup LVM
       1.  create volume group `temp_vg`
       2.  create logical volume `lv_swap` 4GB
       3.  create logical volume `lv_temp` 4GB
   4.  set lv_swap type swap
   5.  set lv_temp type ext4 mount `/tmp`
-  Install Basic Server and OpenSSH Server

## Post Install 

I prefer to do most operations using PuTTY versus using the virtual machine console to allow for easy copy and paste to accomplish tasks. To do this you need to determine the IP address of the virtual machine using `ip a` then connect from your host.

# Securing the System Part One - The Filesystem Menace

This step creates files to be used during a GParted session to configure the BTRFS file system for optimal security, stability and recoverability. The guides for SLES and for Arch Linux were used as a template and applied to Ubuntu Linux.

The common theme of using BTRFS for the operating system file system is to have a single point for snapshot creation and if needed, recovery and separation of some directories to separate snapshots or filesystems. This document does the following:

-  `/tmp` is already on a separate file system at installation, modification of /etc/fstab is the only thing required
-  `/home` is already on a separate sub volume, modification of /etc/fstab is the only thing required
-  `/boot/grub` contains a directory that should be preserved on snapshot recovery
-  `/var` contains directories that should not be included in a system snapshot due to their volatile nature or for preservation of logs or data to be used in problem determination before recovering a snapshot
-  `/var/log` is moved to a separate sub volume and mounted at startup - `@var-log`
-  sub volume `@snapshot` is created to use when creating snapshots of the system; it can be mounted for the snapshot than unmounted when the snapshot is complete keeping it separate from the root sub volume
-  creates a /etc/fstab to copy

The sub volume layout differs from SUSE Linux Enterprise Server as follows:

-  `/boot` .. uses Grub not Grub2
-  `/home` .. is already a separate mount in subvolume @home
-  `/opt, /var/opt` .. would be part of updates so IMO would be part of a rollback is something gets screwed up ???
-  `/srv` .. if used, would already have a separate disk and/or file system mounted on it ???
-  `/tmp` .. already on a separate disk and mount
-  `/usr/local` .. same as `/opt` ???
-  `/var/lib/mail` .. is `/var/mail` on Ubuntu
-  `/var/lib/mariadb, /var/lib/mysql, /var/lib/pgqsl` .. if used, would already have a separate disk mounted on it ??? also no need to disable copy-on-write since file system would be specific to best performance for database used ???

When editing the /etc/fstab the UUID is the most important thing to preserve; that is the unique identifier for the first partition on the first disk. The mount options are modified and `/var/log` is added as a sub volume.

## Questions ?

-  `/var/snap` ??? I assume this is for the snap architecture so would not be part of a system snapshot?  At this time, create a sub volume to use for this directory ???
-  bind `/var/tmp` to `/tmp` ??? technically `/var/tmp` should persist between restarts while `/tmp` does not so binding it to temp is not recommended ???
-  Per UK site: temporarily make the `/tmp` directory executable before running `apt-get` and remove execution flag afterwards. This is because sometimes apt writes files into `/tmp` and executes them from there --- I have NEVER been able to get this to work --- ???

```
echo -e "DPkg::Pre-Invoke{\"mount -o remount,exec /tmp\";};\nDPkg::Post-Invoke {\"mount -o remount /tmp\";};" >> /etc/apt/apt.conf.d/99tmpexec
chmod 644 /etc/apt/apt.conf.d/99tmpexec
```

## Filesystem Hardening Part 1

Notes: *Technically I could probably `sed` or `cat` but copy and paste seems so damned easy ... *

```Bash

sudo -i
chmod 1777 -R /tmp
chown root.root /tmp
chmod 700 "/home/sadmin"

cd
cp /etc/fstab ~/fstab
vi fstab
# /etc/fstab: static file system information.
UUID=~A1~ /               btrfs   defaults,noatime,subvol=@ 0       1
UUID=~A1~ /home           btrfs   defaults,noatime,nodev,nosuid,subvol=@home 0 2
/dev/mapper/temp_vg/lv_temp    /tmp     ext4    defaults,noatime,nodev,nosuid 0 2
/dev/mapper/temp_vg/lv_swap    none     swap    sw              0       0
UUID=~A1~ /var/log        btrfs   defaults,noatime,subvol=@var-log,compress 0 2
:x
vi todo
function btrfs_move {
	mv ${1} ${1}.bkp
	btrfs subvolume create ${1}
	if [[ $# -ge 2 ]]; then chmod ${2} ${1}; else chmod 755 ${1}; fi
	if [[ $# -eq 4 ]]; then chown ${3}:${4} ${1}; fi
	if [ "$(ls -A ${1}.bkp)" ]; then cp -aur ${1}.bkp/* ${1}/; fi
	rm -rf ${1}.bkp
}
cd /b/@/boot/grub
btrfs_move i386-pc
cd /b/@/var
btrfs_move cache
btrfs_move mail 2775 root mail
btrfs_move spool
btrfs_move snap
btrfs_move tmp 1775
btrfs_move crash 1777
cd /b
btrfs subvolume create @snapshots
btrfs subvolume create @var-log
chattr +c ./@var-log
cp -aur @/var/log/* @var-log/
rm -rf @/var/log/*
rm /b/@/etc/fstab
mv /b/@/root/fstab /b/@/etc/fstab
cd /
umount /b
sync
shutdown -h now
:x
btrfs subvolume create /.snapshots
shutdown -h now
```

## Filesystem Hardening Part 2

Attach the GParted .iso and start the system. Choose default, default, default, 2 (command line) then do:

```
mkdir /b
mount /dev/sda1 /b
cp /b/@/root/todo /todo
. todo
```

After restart, the GParted .iso will be ejected from the CD-ROM and the system will start with a secured file system.

# Securing the System Part Two - Attack of the Cloned (Advice)

This next session attempts to combine all of the items the experts agree upon into something that can be implemented in Server 18.04.

## Update System and Packages

First, if you already have apt-cacher-ng setup point apt there.

Installed
-  The `deborphan` technically is not needed anymore but Ubuntu does not do a complete job of keeping itself clean so install it.
-  Both `apparmor-profiles` and `apparmor-utils` are recommended by the UK
-  `auditd`

Removed
-   The `popularity-contest` package sets up a cron job that will periodically anonymously submit to the Ubuntu developers statistics about the most used Ubuntu packages on this system. *This information helps us making decisions such as which packages should go on the first CD. It also lets us improve future versions of Ubuntu so that the most popular packages are the ones which are installed automatically for new users.* Pass...
-   The `unattended-upgrades` package can be used to automatically install updated packages, and can be configured to update all packages or just install security updates. *This is a personal choice; it causes more problems than it solves? Most people have well thought out update systems and processes?*

```Bash
sudo -i
echo 'Acquire::http { Proxy "http://192.168.0.184:3142"; };' | tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
apt update
apt -y full-upgrade
apt install -y apparmor-profiles apparmor-utils auditd deborphan
apt remove -y popularity-contest unattended-upgrades
```

## /etc

Combination of all the "expertise" for securing files in the /etc directory.

```Bash
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

```

## AppArmor

Ah, yes. AppArmor. The part of Linux everyone recommends disabling so their crap works and the part everyone blames when things do not work. Personally, I have not found any issues yet. Please update this if you do.

I started with a combination of multiple sources then referenced the [Ubuntu Server Guide](https://help.ubuntu.com/lts/serverguide/apparmor.html)

*Everything here seems more than reasonable although there should be recommendations for logging enforced rules and nagging performed by AppArmor?*

```Bash
aa-enforce /etc/apparmor.d/usr.sbin.avahi-daemon
aa-enforce /etc/apparmor.d/usr.sbin.dnsmasq
aa-enforce /etc/apparmor.d/bin.ping
aa-enforce /etc/apparmor.d/usr.sbin.rsyslogd
```

References from Ubuntu's Server page

-  [AppArmor Administration Guide](http://www.novell.com/documentation/apparmor/apparmor201_sp10_admin/index.html?page=/documentation/apparmor/apparmor201_sp10_admin/data/book_apparmor_admin.html) for advanced configuration options.
-  [AppArmor Community Wiki](https://help.ubuntu.com/community/AppArmor) 
-  [OpenSUSE AppArmor](http://en.opensuse.org/SDB:AppArmor_geeks) page is another introduction to AppArmor.
-  [#ubuntu-server](http://freenode.net) IRC channel

![Good Luck](https://proxy.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.quickmeme.com%2Fimg%2F3d%2F3dfb55aad54797770e4680579a7dbc6291dbba1d433f26e4e3170ced9f08fa24.jpg&f=1)

## auditd

Use [auditd](http://manpages.ubuntu.com/manpages/bionic/man8/auditd.8.html) to monitor changes and executions within `/tmp` and administrator access to `/home` directories.

```Bash
cat > /etc/audit/rules.d/tmp-monitor.rules << FOOD
-w /tmp/ -p wa -k tmp_write
-w /tmp/ -p x -k tmp_exec
FOOD
cat  > /etc/audit/rules.d/admin-home-watch.rules << FOOD
-a always,exit -F dir=/home/ -F uid=0 -C auid!=obj_uid -k admin_home_user
FOOD
augenrules
systemctl restart auditd.service
```

## Privacy

>>By default Ubuntu has some features enabled which can be a privacy concern. To disable these features take the following steps:

```Bash
echo "Disable Apport error reporting service"
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
```

## UFW Firewall

Evaluate the allow for OpenSSH to suit your environment.

```
ufw status verbose
ufw allow from 127.0.0.1
ufw allow from 192.168.0.0/24 to any app OpenSSH
ufw deny from any to any app OpenSSH
ufw logging on
ufw enable
```

# Securing the System Part Three - Revenge of the Sith (em Administrators)

This section is a collection of next steps that appear in some hardening guides, may or may not be useful depending on your situation, or may not be current (i.e. recommended with 16.04 but not 18.04), etc.

-  `sudo apt install -y fail2ban` 
-  `sudo apt install -y rkhunter` 50.4 MB - **Installer asks for a mail integration**
-  `dpkg-statoverride --update --add root adm 4750 /bin/su` - prevent standard user executing su (switch user) 

## Fail2Ban

Fail2Ban monitors log files for patterns similar to various attacks and runs scripts (usually blocking the source IP address) in response.

(https://github.com/fail2ban)
(https://blog.vigilcode.com/2011/05/ufw-with-fail2ban-quick-secure-setup-part-ii/)

## Rootkit Hunter

Rootkit Hunter is a security monitoring and analyzing tool for POSIX compliant systems.

(https://sourceforge.net/projects/rkhunter/files/)

# Securing the System Part Four - A New Hope

This sections does not have anything in it yet; I was just keeping with the Star Wars movie theme...

# Securing the System Part Five - The Ubuntu Strikes Back

This sections revists some common items I have seen over the years that I am not qualified to address but will list here with my comments.

## Secure shared memory

*Shared memory can be used in an attack against a running service, so it is always best to secure that portion of memory. You can do this by modifying the `/etc/fstab` file.*

```Bash
sudo vi /etc/fstab
tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0
:x
sudo shutdown -r 1; exit
```

I do not know enough about shared memory to make a qualified response to this information but what goes through my head is since this security recommendation has been around since 14.04 and newer Ubuntu systems are being designed to not be monolithic servers to run a collection of applications but instead run either operating system or application containers is securing shared memory still an issue? Or has it been addressed by modern updates to the various system components or is part of the container systems being used and what role does `snap` play in all of this?

## Harden the networking layer

*There is a very simple way to prevent source routing of incoming packets*

```Bash
sudo -i
cat > /etc/sysctl.conf << FOOD
# IP Spoofing protection
​net.ipv4.conf.all.rp_filter = 1
​net.ipv4.conf.default.rp_filter = 1
​
​# Ignore ICMP broadcast requests
​net.ipv4.icmp_echo_ignore_broadcasts = 1
​
​# Disable source packet routing
​net.ipv4.conf.all.accept_source_route = 0
​net.ipv6.conf.all.accept_source_route = 0 
​net.ipv4.conf.default.accept_source_route = 0
​net.ipv6.conf.default.accept_source_route = 0
​
​# Ignore send redirects
​net.ipv4.conf.all.send_redirects = 0
​net.ipv4.conf.default.send_redirects = 0
​
​# Block SYN attacks
​net.ipv4.tcp_syncookies = 1
​net.ipv4.tcp_max_syn_backlog = 2048
​net.ipv4.tcp_synack_retries = 2
​net.ipv4.tcp_syn_retries = 5
​
​# Log Martians
​net.ipv4.conf.all.log_martians = 1
​net.ipv4.icmp_ignore_bogus_error_responses = 1
​
​# Ignore ICMP redirects
​net.ipv4.conf.all.accept_redirects = 0
​net.ipv6.conf.all.accept_redirects = 0
​net.ipv4.conf.default.accept_redirects = 0 
​net.ipv6.conf.default.accept_redirects = 0
​
​# Ignore Directed pings
​net.ipv4.icmp_echo_ignore_all = 1
FOOD
sysctl -p.
```

From the `/etc/sysctl.conf` comments: *Additional settings - these settings can improve the network security of the host and prevent against some network attacks including spoofing attacks and man in the middle attacks through redirection. Some network environments, however, require that these settings are disabled so review and enable them as needed.*

## Prevent IP spoofing

*This one is quite simple and will go a long way to prevent your server's IP from being spoofed.*

```Bash
sudo -i
cat > /etc/host.conf << FOOD
# The "order" line is only used by old versions of the C library.
​order bind,hosts
​nospoof on
FOOD
```

Still needed?

# Securing the System Part Six - Return of the Juju

This section is more for the future. Most large organizations use Chef, Puppet, Ansible, etc. to provision servers or containers and they either come with pre-built recipies/scripts for secure distributions or most people create them.

# Resources

-  [UK](https://www.ncsc.gov.uk/collection/end-user-device-security/platform-specific-guidance/ubuntu-18-04-lts)
-  [BTRFS](https://rootco.de/2018-01-19-opensuse-btrfs-subvolumes/)
-  [BTRFS](https://susedoc.github.io/doc-sle/SLE12SP3/SLES-storage/html/cha-filesystems.html#sec-filesystems-major-btrfs)
-  [BTRFS](https://wiki.archlinux.org/index.php/Snapper#Suggested_filesystem_layout)
-  [BTRFS](https://www.reddit.com/r/Ubuntu/comments/7qp9gb/btrfs_pop_os_recommended_subvolumes/)
-  [popcon](https://askubuntu.com/questions/57808/what-is-the-popularity-contest-package-for#57811)
-  [Hardening](https://help.ubuntu.com/lts/serverguide/automatic-updates.html)
-  [Hardening](https://blog.vigilcode.com/2011/04/ubuntu-server-initial-security-quick-secure-setup-part-i/)
-  [Hardening](https://www.techrepublic.com/article/how-to-harden-ubuntu-server-16-04-security-in-five-steps/)

