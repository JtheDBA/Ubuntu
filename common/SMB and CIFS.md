# SMB and CIFS

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

>> Server Message Block (SMB), one version of which was also known as Common Internet File System (CIFS /sɪfs/) is a network communication protocol[3] for providing shared access to files, printers, and serial ports between nodes on a network. It also provides an authenticated inter-process communication mechanism. Most usage of SMB involves computers running Microsoft Windows, where it was known as "Microsoft Windows Network" before the introduction of Active Directory. Corresponding Windows services are LAN Manager Server for the server component, and LAN Manager Workstation for the client component.

# Connecting to Windows Shares

I have tested connections from Ubuntu 18.04 to shares on the following

-  //192.168.0.080/stuff - Windows Server 2016 server
-  //192.168.0.129/stuff - Netgear ReadyNAS 104
-  //192.168.0.130/stuff - Synology DS-218+ NAS
-  //192.168.0.144/stuff - Windows 10 Professional desktop

## Configuring Targets

For the Synology DS-218+ NAS I modified some settings: Control Panel > File Services > SMB/AFP/NFS | SMB Advanced Settings

-  Maximum SMB protocol SMB3
-  Minimum SMB protocol SMB2
-  Enabled Opportunistic Locking
-  Enabled Local Master Browser

I found no obvious settings on the Netgear ReadyNAS 104.

## Some Questions

**Where should shares be mounted?**

According to [Filesystem Hierarchy Standard](http://www.pathname.com/fhs/pub/fhs-2.3.html#MEDIAMOUNTPOINT) /media is a mount point for removeable media and /mnt is a mount point for mounting a filesystem temporarily.
And /srv contains site-specific data which is *served* by this system.
I know this doesn't matter and technically a network share could be considered temporary and removable or persistent (mounted at startup).
So I simply chose /mnt for everything mounted at startup or later. Later, /media could be used for "removable" (i.e. mount, do something, umount, carry on).

## Setup Ubuntu

1.  become root
2.  install cifs-utils
3.  create a hidden credentials file in /root with the file containing two lines:
    1.  username=joel
    2.  password=password
4.  close file and protect that file
5.  create all directories in /mnt
6.  for each user create a directory in /media for individual user mounts (not used)
7.  backup
8.  add mounts to /etc/fstab
    1.  Windows Server 2016 share, mounted at startup with full read write using current version of SMB
    2.  Netgear ReadyNAS 104 share, mounted at startup with full read write using highest version of SMB the device supported
    3.  Synology DS-218+ NAS share, not mounted at startup using highest version of SMB the device supported
    4.  Windows 10 Professional share, not mounted at startup using current version of SMB
9.  close file

```Bash
sudo -i
apt install -y cifs-utils
cat > ~/.smbcredentials << FOOD
username=joel
password=password
FOOD
chmod 0600 ~/.smbcredentials
mkdir -p /mnt/cifs/{080,144,129,130}/stuff
for FOO in `awk -F: '($3>=1000 && $3 <60000) {print $1}' /etc/passwd`; do mkdir -p /media/${FOO}/stuff; chmod -R 770 /media/${FOO}; chown -R ${FOO}:${FOO} /media/${FOO}; done
cp /etc/fstab /etc/fstab.bkp
cat >> /etc/fstab << FOOD
//192.168.0.080/stuff   /mnt/cifs/080/stuff    cifs defaults,nosuid,nodev,credentials=/root/.smbcredentials,uid=joel,gid=joel,file_mode=0777,dir_mode=0777,iocharset=utf8,vers=3.1.1  0 0
//192.168.0.129/stuff   /mnt/cifs/129/stuff    cifs defaults,nosuid,nodev,credentials=/root/.smbcredentials,uid=joel,gid=joel,file_mode=0777,dir_mode=0777,iocharset=utf8,vers=3.0  0 0
//192.168.0.130/stuff   /mnt/cifs/130/stuff    cifs noauto,rw,user,iocharset=utf8,vers=3.0  0 0
//192.168.0.144/stuff   /mnt/cifs/144/stuff    cifs noauto,rw,user,iocharset=utf8,vers=3.1.1  0 0
mount /mnt/cifs/080/stuff
mount /mnt/cifs/129/stuff
FOOD
```

I found through frustration and trial and error that adding the ,vers= solved most if not all mount issues. Sometime the mount would work but revert to SMB2 or SMB/CIFS/SMB1 which work but are inferior protocols.

## Mounting Shares Manually

```Bash
if ! (findmnt /mnt/cifs/130/stuff); then mount.cifs //192.168.0.130/stuff /mnt/cifs/130/stuff; fi
if ! (findmnt /mnt/cifs/144/stuff); then mount.cifs //192.168.0.144/stuff /mnt/cifs/144/stuff user=joelmathias@live.com; fi
```

# Sharing Shares

## Install SAMBA Server

This is a work in progress and only for a standalone server. Additional recommendations or content would be greatly appreciated.

1.  become root
2.  install samba-server and copy a backup and a clean version of the configuration file to /root
3.  change the name of the WORKGROUP
4.  optional; remove the section for printers assuming anyone using printers would be using MFD or something attached elsewhere
5.  ? cannot remember why I did the following to prevent Unix/Samba password synchronization ?
6.  copy our base template smb.conf to `/etc`
7.  optional; the next block enables home directories as shares for individual users
8.  choose one of the next two blocks
    1.  sets up a single share called `shared` in directory `/srv/samba/shared`
    2.  sets up a multiple shares in directory `/srv/samba` based on the heredoc input with the share/subdirectory:description
9.  set up ownership and permissions
10. add all users to SAMBA password service, entering a password for each user
11. restart the SAMBA services
12. configure `ufw` i.e. [Uncomplicated Firewall](https://wiki.archlinux.org/index.php/Uncomplicated_Firewall) - remove ALLOW lines for any networks that do not apply

```Bash
sudo -i
apt install tasksel
tasksel install samba-server
cp /etc/samba/smb.conf ~/smb.conf_backup
grep -v -E "^#|^;" ~/smb.conf_backup | grep . > smb.conf

sed -ie 's/WORKGROUP/7497HOME/' smb.conf

sed -ie '/\[printers\]/,$d' smb.conf

sed -ie '/obey pam/,/usershare allow guests/d' smb.conf
sed -ie '/unix password sync/,/usershare allow guests/d' smb.conf

cat smb.conf > /etc/samba/smb.conf

cat >> /etc/samba/smb.conf << FOOD
[homes]
	comment = Home Directories
	browseable = yes
	read only = no
FOOD

mkdir -p /srv/samba/shared
cat >> /etc/samba/smb.conf << FOOD
[shared]
  comment = Shared Directories
  path = /srv/samba/shared
  browsable = yes
  read only = no
  guest ok = no
  valid users = @sambashare
FOOD

awk -F: '{system("mkdir -p /srv/samba/" $1)};{printf"[%s]\n\tcomment = %s\n\tpath = /srv/samba/%s\n\tbrowsable = yes\n\tread only = no\n\tguest ok = no\n\tvalid users = @sambashare\n",$1,$2,$1}' >> /etc/samba/smb.conf << FOOD
video:Our Private Home Video Collection
audio:Legally Purchased Music and Podcasts
download:Software and Disk Image Files
movies:Our Collection of Legally Purchased Movies in Electronic Format
tv:Our Collection of Legally Purchased TV Series Episodes in Electronic Format
documents:Electronic Documents by Year
FOOD

chown -R nobody:sambashare /srv/samba/*
chmod -R 2775 /srv/samba/*

for FOO in `awk -F: '($3>=1000 && $3 <60000) {print $1}' /etc/passwd`; do smbpasswd -a ${FOO}; usermod -aG sambashare ${FOO}; done

systemctl restart smbd
systemctl restart nmbd

ufw app update Samba
ufw allow from 10.0.0.0/8 to any app Samba
ufw allow from 172.16.0.0/12 to any app Samba
ufw allow from 192.168.0.0/16 to any app Samba
ufw deny from any to any app Samba
ufw reload
```

# TODO

1. configure Samba to use existing Unix password
2. configure Samba as a domain controller
3. script mount process

# References

-  [mount.cifs - Linux man page](https://linux.die.net/man/8/mount.cifs)
-  [SMB](https://en.wikipedia.org/wiki/Server_Message_Block) above quote
-  [Ubuntu wiki](https://wiki.ubuntu.com/MountWindowsSharesPermanently)
