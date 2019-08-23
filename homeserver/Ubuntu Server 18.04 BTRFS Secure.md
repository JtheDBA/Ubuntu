# Secure Ubuntu Server 18.04 BTRFS

Author: Joel Mathias (jmathias@cscc.edu, joel.c.mathias@gmail.com)
Revisions:

## Goal

The goal of this document is to create a secure installation of Ubuntu Server using the BTRFS file system. This is an attempt to combine numerous online resources into something that is both reasonable and implementable in a small to midsize virtualized environment.

# Create the Virtual Machine

Two storage devices are created for the virtual machine. The first device is for the BTRFS based operating system and the second for temporary file systems.

The separation of devices was a consideration for environments using a disaster recovery software system. For example, at Columbus State Community College we use Zerto. The Zerto best practices guide recommends:

When configuring a VPG, Zerto Virtual Replication provides an option to mark individual volumes as "Temp Data Disk" (formerly known as "Swap"). This functionality is extremely useful when your operating system or database has a dedicated volume for swap, virtual memory, temporary backups, or files that are only relevant to a live and running machine, and are useless following a reboot. When one of the protected VM volumes is marked as a "Temp Data Disk" volume, upon saving the VPG, the volume will undergo an Initial Sync. However, all subsequent IOs to that volume will be ignored. The purpose of the Initial Sync's is to make sure the full remote file system is available in the event of a Failover Test, Live Failover, Move, or Offsite Clone operation.

This makes sense. You would not want temporary or volatile data being replicated over a leased line to a remote site used for disaster recovery.

## Installation

```
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

### User
System Administrator
sadmin

### Partitioning
disk 0 
-  partition BTRFS /
disk 1
-  partition LVM

Setup LVM
Create LVM volume group temp_vg
-  logical volume lv_swap 4GB swap
-  logical volume lv_temp 4GB ext4 /tmp

Install Basic Server and OpenSSH Server

## Post Install 

I prefer to do most operations using PuTTY versus using the virtual machine console to allow for easy copy and paste to accomplish tasks. To do this you need to determine the IP address of the virtual machine then connect from your host:

```
ip a
"C:\Program Files (x86)\PuTTY\putty.exe" joel@192.168.0.33
```

# Secure the File System

This step creates files to be used during a GParted session to configure the BTRFS file system for optimal security, stability and recoverability. The guide used for SLES and for Arch Linux was used as a template and applied to Ubuntu Linux.

The common theme of using BTRFS for the operating system file system is to have a single point for snapshot creation and if needed, recovery and separation of some directories to separate snapshots or filesystems. This document does the following:

-  /tmp is already on a separate file system at installation, modification of /etc/fstab is the only thing required
-  /home is already on a separate sub volume, modification of /etc/fstab is the only thing required
-  /boot/grub contains a directory that should be preserved on snapshot recovery
-  /var contains directories that should not be included in a system snapshot due to their volatile nature or for preservation of logs or data to be used in problem determination before recovering a snapshot
-  /var/log is moved to a separate sub volume and mounted at startup - @var-log
-  sub volume snapshot is created to use when creating snapshots of the system; it can be mounted for the snapshot than unmounted when the snapshot is complete keeping it separate from the root sub volume
-  creates a /etc/fstab to copy

The sub volume layout differs from SUSE Linux Enterprise Server as follows:

-  /boot .. uses Grub not Grub2
-  /home .. is already a separate mount in subvolume @home
-  /opt, /var/opt .. would be part of updates so IMO would be part of a rollback is something gets screwed up ???
-  /srv .. if used, would already have a separate disk mounted on it ???
-  /tmp .. already on a separate disk and mount
-  /usr/local .. same as opt ???
-  /var/lib/mail .. is /var/mail on Ubuntu
-  /var/lib/mariadb, /var/lib/mysql, /var/lib/pgqsl .. if used, would already have a separate disk mounted on it ??? also no need to disable copy-on-write since file system would be specific to best performance for database used ???

When editing the /etc/fstab the UUID is the most important thing to preserve; that is the unique identifier for the first partition on the first disk. The mount options are modified and /var/log is added as a sub volume.

Questions ?

-  /var/snap ??? I assume this is for the snap architecture so would not be part of a system snapshot? At this time, create a sub volume to use for this directory ???
-  bind /var/tmp to /tmp ??? technically /var/tmp should persist between restarts while /tmp does not so binding it to temp is not recommended ???
-  Per UK site: temporarily make the /tmp directory executable before running apt-get and remove execution flag afterwards. This is because sometimes apt writes files into /tmp and executes them from there --- I have NEVER been able to get this to work --- ???
```
echo -e "DPkg::Pre-Invoke{\"mount -o remount,exec /tmp\";};\nDPkg::Post-Invoke {\"mount -o remount /tmp\";};" >> /etc/apt/apt.conf.d/99tmpexec
chmod 644 /etc/apt/apt.conf.d/99tmpexec
```

Final Filesystem Hardening TODO:

```
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

Attach the GParted .iso and restart.

```
default
default
default
2 Choose command line

mkdir /b
mount /dev/sda1 /b
cp /b/@/root/todo /todo
. todo
```

After restart, the GParted .iso will be ejected from the virtual CD-ROM and the system will start with a secured file system.

# Hardening Part 1

This next session attempts to combine all of the items the experts agree upon into something that can be implemented in Server 18.04.

## Update System and Packages

First, if you already have apt-cacher-ng setup point apt there.

Installed
-  The deborphan technically is not needed anymore but Ubuntu does not do a complete job of keeping itself clean so install it.
-  Both apparmor-profiles and apparmor-utils are recommended by 
-   auditd 

Removed
-   The popularity-contest package sets up a cron job that will periodically anonymously submit to the Ubuntu developers statistics about the most used Ubuntu packages on this system.  This information helps us making decisions such as which packages should go on the first CD. It also lets us improve future versions of Ubuntu so that the most popular packages are the ones which are installed automatically for new users.
-   The unattended-upgrades package can be used to automatically install updated packages, and can be configured to update all packages or just install security updates.

```
sudo -i
echo 'Acquire::http { Proxy "http://192.168.0.184:3142"; };' | tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
apt update
apt -y full-upgrade
apt install -y apparmor-profiles apparmor-utils auditd deborphan
apt remove -y popularity-contest unattended-upgrades
```

## /etc

Combination of all the "expertise" for securing files in the /etc directory.

```
echo -e "Aaron Toppance recommends disabling the following pieces of dynamic logon information because they phone home and slow things down - who am I to argue ???""
sed -ie '/motd=/ s/session/#session/' /etc/pam.d/login
sed -ie '/motd=/ s/session/#session/' /etc/pam.d/sshd
echo -e "Configuring home directories and shell access..."
sed -ie '/^DIR_MODE=/ s/=[0-9]*\+/=0700/' /etc/adduser.conf
sed -ie '/^UMASK\s\+/ s/022/077/' /etc/login.defs
echo -e "Disable shell access for new users (not affecting the existing admin user).""
sed -ie '/^SHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/default/useradd
sed -ie '/^DSHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/adduser.conf
```

## AppArmor

Ah, yes. AppArmor. The part of Linux everyone recommends disabling so their crap works and the part everyone blames when things do not work. Personally, I have not found any issues yet. Please update this if you do.

Everything here seems more than reasonable although I do not see a mechanism for logging enforced or monitored violations.

```
aa-enforce /etc/apparmor.d/usr.bin.firefox
aa-enforce /etc/apparmor.d/usr.sbin.avahi-daemon
aa-enforce /etc/apparmor.d/usr.sbin.dnsmasq
aa-enforce /etc/apparmor.d/bin.ping
aa-enforce /etc/apparmor.d/usr.sbin.rsyslogd
```

## auditd

Configure the auditd to monitor changes and executions within /tmp and administrator access to /home directories

```
if [ ! -f /etc/audit/rules.d/tmp-monitor.rules ]; then
-w /tmp/ -p wa -k tmp_write
-w /tmp/ -p x -k tmp_exec" > /etc/audit/rules.d/tmp-monitor.rules
fi
if [ ! -f /etc/audit/rules.d/admin-home-watch.rules ]; then
-a always,exit -F dir=/home/ -F uid=0 -C auid!=obj_uid -k admin_home_user" > /etc/audit/rules.d/admin-home-watch.rules
fi
augenrules
systemctl restart auditd.service
```

## Disable error reporting services

```
systemctl stop apport.service
systemctl disable apport.service
systemctl mask apport.service
systemctl stop whoopsie.service
systemctl disable whoopsie.service
systemctl mask whoopsie.service
sed -ie '/^enabled=1$/ s/1/0/' /etc/default/apport
sed -ie '/^enabled=1$/ s/1/0/' /etc/default/whoopsie
```

## UFW Firewall

```
ufw status verbose
ufw deny from 192.168.0.1 to any app OpenSSH
ufw allow from 192.168.0.0/24 to any app OpenSSH
ufw allow from 127.0.0.1
ufw logging on
ufw enable
```


#

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Lockdown Gnome screensaver lock settings
echo -e "${HIGHLIGHT}Configuring Gnome screensaver lock settings...${NC}"
mkdir -p /etc/dconf/db/local.d/locks
echo "[org/gnome/desktop/session]
idle-delay=600

[org/gnome/desktop/screensaver]
lock-enabled=1
lock-delay=0" > /etc/dconf/db/local.d/00_screensaver-lock

echo "/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-enabled
/org/gnome/desktop/screensaver/lock-delay" > /etc/dconf/db/local.d/locks/00_screensaver-lock

dconf update





# Prevent standard user executing su.
echo -e "${HIGHLIGHT}Configure su execution...${NC}"
dpkg-statoverride --update --add root adm 4750 /bin/su


sed -ie '/^enabled=1$/ s/1/0/' /etc/default/apport
# WTFDTD?
dpkg-statoverride --update --add root adm 4750 /bin/su
#
# 
#
#
#
#


apt install -yf libpam-pwquality

systemctl stop apport.service
systemctl disable apport.service
systemctl mask apport.service

echo -e "${HIGHLIGHT}Configuring additional directory permissions...${NC}"

chmod o-w /var/crash
chmod o-w /var/tmp

#





function promptPassphrase {
	PASS=""
	PASSCONF=""
	while [ -z "$PASS" ]; do
		read -s -p "Passphrase: " PASS
		echo ""
	done
	
	while [ -z "$PASSCONF" ]; do
		read -s -p "Confirm passphrase: " PASSCONF
		echo ""
	done
	echo ""
}

function getPassphrase {
	promptPassphrase
	while [ "$PASS" != "$PASSCONF" ]; do
		echo "Passphrases did not match, try again..."
		promptPassphrase
	done
}

if [[ $UID -ne 0 ]]; then
 echo "This script needs to be run as root (with sudo)."
 exit 1
fi

# Get the admin user.
users=($(ls /home))
echo "Existing users:"
echo
for index in ${!users[*]}
do
	echo -e "\t[$index]: " ${users[$index]}
done
echo

while [ -z "$SELECTION" ]; do read -p "Please select the user you created during the Ubuntu installation: " SELECTION; done
ADMINUSER=${users[$SELECTION]}
if [ -z "$ADMINUSER" ]; then
	echo "Invalid user selected. Please run the script again."
	exit
fi

# Get the username for the primary user.
echo
echo "Please enter a username for the primary device user that will be created by this script."
while [ -z "$ENDUSER" ]; do read -p "Username for primary device user: " ENDUSER; done
if [ -d "/home/$ENDUSER" ]; then
	if [ "$ENDUSER" == "$ADMINUSER" ]; then
		echo "Primary user cannot be the same as the admin user."
		exit
	fi

	read -p "The username you entered already exists. Do you want to continue? [y/n]: " CONFIRM
	if [ "$CONFIRM" != "y" ]; then
		exit
	fi
fi

echo "If you are not using the default internet repositories you should configure this before running this script."
echo "You should also have an active network connection to the repositories."
read -p "Continue? [y/n]: " CONFIRM
if [ "$CONFIRM" != "y" ]; then
 exit
fi

echo -e "${HIGHLIGHT}Running system updates...${NC}"


# Configuring mount and grub. We need to make sure the script is running for the first time.
echo -e "${HIGHLIGHT}Configuring fstab...${NC}"
read -p "Is this the first time you run the post-install script? [y/n]: " CONFIRM
if [ "$CONFIRM" == "y" ]; then
	# Update fstab.
	echo -e "${HIGHLIGHT}Writing fstab config...${NC}"
	sed -ie '/\s\/home\s/ s/defaults/defaults,noexec,nosuid,nodev/' /etc/fstab
	EXISTS=$(grep "/tmp/" /etc/fstab)
	if [ -z "$EXISTS" ]; then
		echo "none /tmp tmpfs rw,noexec,nosuid,nodev 0 0" >> /etc/fstab
	else
		sed -ie '/\s\/tmp\s/ s/defaults/defaults,noexec,nosuid,nodev/' /etc/fstab
	fi
	echo "none /run/shm tmpfs rw,noexec,nosuid,nodev 0 0" >> /etc/fstab
	# Bind /var/tmp to /tmp to apply the same mount options during system boot
 	echo "/tmp /var/tmp none bind 0 0" >> /etc/fstab
	# Temporarily make the /tmp directory executable before running apt-get and remove execution flag afterwards. This is because
	# sometimes apt writes files into /tmp and executes them from there.
	echo -e "DPkg::Pre-Invoke{\"mount -o remount,exec /tmp\";};\nDPkg::Post-Invoke {\"mount -o remount /tmp\";};" >> /etc/apt/apt.conf.d/99tmpexec
	chmod 644 /etc/apt/apt.conf.d/99tmpexec
fi

# Set grub password.
echo -e "${HIGHLIGHT}Configuring grub...${NC}"
echo "Please enter a grub sysadmin passphrase..."
getPassphrase

echo "set superusers=\"sysadmin\"" >> /etc/grub.d/40_custom
echo -e "$PASS\n$PASS" | grub-mkpasswd-pbkdf2 | tail -n1 | awk -F" " '{print "password_pbkdf2 sysadmin " $7}' >> /etc/grub.d/40_custom
sed -ie '/echo "menuentry / s/echo "menuentry /echo "menuentry --unrestricted /' /etc/grub.d/10_linux
sed -ie '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ module.sig_enforce=yes"/' /etc/default/grub
echo "GRUB_SAVEDEFAULT=false" >> /etc/default/grub
update-grub

# Set permissions for admin user's home directory.
chmod 700 "/home/$ADMINUSER"

# Configure automatic updates.
echo -e "${HIGHLIGHT}Configuring automatic updates...${NC}"
EXISTS=$(grep "APT::Periodic::Update-Package-Lists \"1\"" /etc/apt/apt.conf.d/20auto-upgrades)
if [ -z "$EXISTS" ]; then
	echo "APT::Periodic::Update-Package-Lists \"1\";" >> /etc/apt/apt.conf.d/20auto-upgrades
fi

EXISTS=$(grep "APT::Periodic::Unattended-Upgrade \"1\"" /etc/apt/apt.conf.d/20auto-upgrades)
if [ -z "$EXISTS" ]; then
	echo "APT::Periodic::Unattended-Upgrade \"1\";" >> /etc/apt/apt.conf.d/20auto-upgrades
fi

EXISTS=$(grep "APT::Periodic::AutocleanInterval \"7\"" /etc/apt/apt.conf.d/10periodic)
if [ -z "$EXISTS" ]; then
	echo "APT::Periodic::AutocleanInterval \"7\";" >> /etc/apt/apt.conf.d/10periodic
fi
chmod 644 /etc/apt/apt.conf.d/20auto-upgrades
chmod 644 /etc/apt/apt.conf.d/10periodic

# Prevent standard user executing su.

# Protect user home directories.

# Installing libpam-pwquality 

# Create the standard user.
adduser "$ENDUSER"

# Set some AppArmor profiles to enforce mode.

# Setup auditing.

# Configure the settings for the "Welcome" popup box on first login.
echo -e "${HIGHLIGHT}Configuring user first login settings...${NC}"
mkdir -p "/home/$ENDUSER/.config"
echo yes > "/home/$ENDUSER/.config/gnome-initial-setup-done"
chown -R "$ENDUSER:$ENDUSER" "/home/$ENDUSER/.config"
sudo -H -u "$ENDUSER" ubuntu-report -f send no

# Disable error reporting services

# Lockdown Gnome screensaver lock settings
echo -e "${HIGHLIGHT}Configuring Gnome screensaver lock settings...${NC}"
mkdir -p /etc/dconf/db/local.d/locks
echo "[org/gnome/desktop/session]
idle-delay=600

[org/gnome/desktop/screensaver]
lock-enabled=1
lock-delay=0" > /etc/dconf/db/local.d/00_screensaver-lock

echo "/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-enabled
/org/gnome/desktop/screensaver/lock-delay" > /etc/dconf/db/local.d/locks/00_screensaver-lock

dconf update

# Disable apport (error reporting)

sudo -H -u "$ENDUSER" dbus-launch gsettings set com.ubuntu.update-notifier show-apport-crashes false

# Fix some permissions in /var that are writable and executable by the standard user.

# Turn off privacy-leaking aspects of Unity.
echo -e "${HIGHLIGHT}Configuring privacy settings...${NC}"
EXISTS=$(grep "user-db:user" /etc/dconf/profile/user)
if [ -z "$EXISTS" ]; then
	echo "user-db:user" >> /etc/dconf/profile/user
fi

EXISTS=$(grep "system-db:local" /etc/dconf/profile/user)
if [ -z "$EXISTS" ]; then
	echo "system-db:local" >> /etc/dconf/profile/user
fi
dconf update

# Setting up firewall without any rules.

echo
echo -e "${HIGHLIGHT}Installation complete.${NC}"

read -p "Reboot now? [y/n]: " CONFIRM
if [ "$CONFIRM" == "y" ]; then
	reboot
fi




Each client system would change their APT configuration to use the cache:

```
ech will o 'Acquire::http { Proxy "http://192.168.0.84:3142"; };' | tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
apt update
apt dist-upgrade -y
```




# Resources

https://www.ncsc.gov.uk/collection/end-user-device-security/platform-specific-guidance/ubuntu-18-04-lts
https://rootco.de/2018-01-19-opensuse-btrfs-subvolumes/
https://susedoc.github.io/doc-sle/SLE12SP3/SLES-storage/html/cha-filesystems.html#sec-filesystems-major-btrfs
https://wiki.archlinux.org/index.php/Snapper#Suggested_filesystem_layout
https://www.server-world.info/en/note?os=Ubuntu_18.04&p=realmd
https://wiki.archlinux.org/index.php/Snapper#Suggested_filesystem_layout
https://www.reddit.com/r/Ubuntu/comments/7qp9gb/btrfs_pop_os_recommended_subvolumes/
https://askubuntu.com/questions/57808/what-is-the-popularity-contest-package-for#57811
https://help.ubuntu.com/lts/serverguide/automatic-updates.html

#### Update System and System Updates

If more than 20 Ubuntu based systems are being maintained at your installation we highly recommend having a centralized package cache like apt-cacher-ng. It is quite simple to set up and can be preloaded with packages from disks. Each client will point to the central server instead of the Internet to get updated package indexes and updated packages.
Of course, this requires somebody to maintain a stable but occasionally fragile ecosystem; also likely before a secure image is available (but can be revisited). Recommend proceeding without one for now - Internet access will be required.





sudo -i
echo 'Acquire::http { Proxy "http://192.168.0.184:3142"; };' | tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
apt update
apt -y full-upgrade
apt install -y apparmor-profiles apparmor-utils auditd deborphan
apt remove -y popularity-contest unattended-upgrades
```

## /etc

Combination of all the "expertise" for securing files in the /etc directory.

```
echo -e "Aaron Toppance recommends disabling the following pieces of dynamic logon information because they phone home and slow things down - who am I to argue ???""
sed -ie '/motd=/ s/session/#session/' /etc/pam.d/login
sed -ie '/motd=/ s/session/#session/' /etc/pam.d/sshd
echo -e "Configuring home directories and shell access..."
sed -ie '/^DIR_MODE=/ s/=[0-9]*\+/=0700/' /etc/adduser.conf
sed -ie '/^UMASK\s\+/ s/022/077/' /etc/login.defs
echo -e "Disable shell access for new users (not affecting the existing admin user).""
sed -ie '/^SHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/default/useradd
sed -ie '/^DSHELL=/ s/=.*\+/=\/usr\/sbin\/nologin/' /etc/adduser.conf
```

## AppArmor

Ah, yes. AppArmor. The part of Linux everyone recommends disabling so their crap works and the part everyone blames when things do not work. Personally, I have not found any issues yet. Please update this if you do.

Everything here seems more than reasonable although I do not see a mechanism for logging enforced or monitored violations.

```
aa-enforce /etc/apparmor.d/usr.bin.firefox
aa-enforce /etc/apparmor.d/usr.sbin.avahi-daemon
aa-enforce /etc/apparmor.d/usr.sbin.dnsmasq
aa-enforce /etc/apparmor.d/bin.ping
aa-enforce /etc/apparmor.d/usr.sbin.rsyslogd
```

## auditd

Configure the auditd to monitor changes and executions within /tmp and administrator access to /home directories

```
if [ ! -f /etc/audit/rules.d/tmp-monitor.rules ]; then
-w /tmp/ -p wa -k tmp_write
-w /tmp/ -p x -k tmp_exec" > /etc/audit/rules.d/tmp-monitor.rules
fi
if [ ! -f /etc/audit/rules.d/admin-home-watch.rules ]; then
-a always,exit -F dir=/home/ -F uid=0 -C auid!=obj_uid -k admin_home_user" > /etc/audit/rules.d/admin-home-watch.rules
fi
augenrules
systemctl restart auditd.service
```

## Disable error reporting services

```
systemctl stop apport.service
systemctl disable apport.service
systemctl mask apport.service
systemctl stop whoopsie.service
systemctl disable whoopsie.service
systemctl mask whoopsie.service
sed -ie '/^enabled=1$/ s/1/0/' /etc/default/apport
sed -ie '/^enabled=1$/ s/1/0/' /etc/default/whoopsie
```

## UFW Firewall

```
ufw status verbose
ufw deny from 192.168.0.1 to any app OpenSSH
ufw allow from 192.168.0.0/24 to any app OpenSSH
ufw allow from 127.0.0.1
ufw logging on
ufw enable
```


#

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Lockdown Gnome screensaver lock settings
echo -e "${HIGHLIGHT}Configuring Gnome screensaver lock settings...${NC}"
mkdir -p /etc/dconf/db/local.d/locks
echo "[org/gnome/desktop/session]
idle-delay=600

[org/gnome/desktop/screensaver]
lock-enabled=1
lock-delay=0" > /etc/dconf/db/local.d/00_screensaver-lock

echo "/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-enabled
/org/gnome/desktop/screensaver/lock-delay" > /etc/dconf/db/local.d/locks/00_screensaver-lock

dconf update


# Prevent standard user executing su.
echo -e "${HIGHLIGHT}Configure su execution...${NC}"
dpkg-statoverride --update --add root adm 4750 /bin/su


sed -ie '/^enabled=1$/ s/1/0/' /etc/default/apport
# WTFDTD?
dpkg-statoverride --update --add root adm 4750 /bin/su
#
