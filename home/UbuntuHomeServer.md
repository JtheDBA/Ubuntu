# Ubuntu Home Server

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

Personally I would purchase a NAS storage device that has the abilities create a small virtual machine to handle Ubuntu specific items but that's just me. However, if you needs are one or more of the following and you have the hardware and/or cash to invest in it:

- keep a central Linux package location to save download time and bandwidth
- share files
- keep safe backups of files for multiple computers
- centralized location for items commonly used on Linux
- want to play video to local devices
- want to play music or audio to local devices
- want to keep an image library for personal and/or private photos

then you can follow my "guide" to accomplish most if not all of that. 

**_ IGNORE EVERYTHING BEYOND THIS POINT _***

## Step 1 - Physical or Virtual

[Physical]()

[Virtual](../server/Ubuntu%20Server%2018.04%20Virtual.md)

Pros
-  you can pick which things the guest does better or things the host does better


## Step 2 - Install Base System

1. [BTRFS Based Install](../server/Ubuntu%20Server%2018.04%20BTRFS%20Secure.md)
2. If you plan on supporting multiple Ubuntu or `apt` based physical or virtual computers I would recommend [installing a local apt cache to centralize updates](../common/apt-cacher-ng.md); follow the first steps
3. [Secure Your Server](../server/Ubuntu%20Server%2018.04%20Common%20Secure.md)

## Step 3 - Add Users

```Bash
for

```

## Step 4 - Add Storage

### Physical



### Virtual

If your home server is running in a virtual machine, I would simply find a way to use the host's preferred storage mechanisms. For example; if running in a VM on a NAS - well connect to the storage on NAS. If running in a HyperV Vm on Windows Server make shares and connect to them.


## Step 5 - Let's Share (Files)

1.  [Share files with Windows](../common/SMB%20and%20CIFS.md) - multiple locations

### Step 2b/5b - Local .iso Images

If you installed [apt-cacher-ng](../common/apt-cacher-ng.md) ... above ...

1.  [Keep copies of Ubuntu .iso images locally](../common/Maintaining%20Local%20Images.md) - in one of the above folders
2.  [Load .iso images into cache](../common/apt-cacher-ng.md) - optional steps

## Step 6 - 
## Step 7 - 
## Step 8 - 
## Step 9 - 
## Step 10 - 
## Step 11 - 
## Step 12 - 
## Step 13 - 
## Step 14 - 
## Step 15 - 
## Step 16 - 
## Step 17 - 
## Step 18 - 
## Step 19 - 
## Step 20 - 
## Step 21 - 
## Step 22 - 
## Step 23 - 
## Step 24 - 


-  fail2ban
   -  traefik
      - sonarr
      - plex
      - grafana
      - home assistant
      
   -  db
   -  appdaemon
   -  delugevpn
   -  sanzbd
   -  nzbbin
   


```


../common
../desktop
../lxd
../readme.md
../server
../virtualbox
../common/Docker.md
../common/Join%20Ubuntu%20to%20Active%20Directory%20Domain.md
../common/Open%20Nebula.md
../desktop/Ubuntu%2018.04%20Shell%20in%20Windows%2010.md
../lxd/readme.md
../server/secure_02.sh
../server/Ubuntu%20Server%2018.04%20LVM%20Secure.md

../virtualbox/CIAB.md
../virtualbox/Docker%20Lab.md
../virtualbox/DOS
../virtualbox/Linux
../virtualbox/LXD%20Lab.md
../virtualbox/MariaDB%20Lab.md
../virtualbox/readme.md
../virtualbox/SnapRAID%20Lab.md
../virtualbox/SWAKES%20Media%20Server.md
../virtualbox/Ubuntu%20Desktops%20in%20VirtualBox.md
../virtualbox/Ubuntu%20Mini%20Server%20BASE.md
../virtualbox/DOS/vb.cmd
../virtualbox/DOS/vbupd.cmd
../virtualbox/DOS/visodown.cmd
```