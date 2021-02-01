# Ubuntu Desktops in VirtualBox

## Important

-  Oracle VM VirtualBox Base Packages are freely available for Windows, Mac OS X, Linux and Solaris x86 platforms under GPLv2. **Oracle VM VirtualBox Extension Pack is free for personal, educational or evaluation use under the terms of the [VirtualBox Personal Use and Evaluation License](https://www.virtualbox.org/wiki/VirtualBox_PUEL) on Windows, Mac OS X, Linux and Solaris x-86 platforms. (else $$ varying upon who you ask but $1000 per socket or $50 per user with 200 user minimum)**
-  If on a Windows 10 Host - please [disable Hyper-V](https://www.reddit.com/r/virtualbox/wiki/index/howtomakeavm). 
-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*

This document attempts to simply the installation of Ubuntu desktops into VirtualBox virtual machines using a script for VM creation.

Installing a Linux desktop into a virtual machine is helpful in many ways. You can use a virtual machine to test new versions or different flavors of various desktops. You can also maintain virtual machines to test updates before they are applied to physical Linux desktops.
Some flavors of Linux have software to build a live .iso/DVD from a running installation (i.e. screw up, restore snapshot, etc. yay finally working)

Of course there are some limits and assumptions.

## Assumptions.

-  as with most every other document in this repository, it assumes you have a central apt cache (apt-cacher-ng)
-  the .iso images for Debian/Ubuntu installers are in a central location
-  a common VirtualBox script is used to setup variables in a command prompt / shell

## Host Setup

### Windows 10

*99.9% of the time when something goes wrong (especially since version 6.1 launched) one of the following 2 issues is the problem:*

-  *You are running Windows 10, and you haven't disabled Hyper-V. You need to follow the steps in the section below.*
-  *You have not enabled hardware virtualization in your BIOS. You can either do that (easy method) or downgrade to v6.0 or v5.2 (lame method).*

#### Disabling Hyper-V

*You need to get to the "Windows Features": Click the Start button. Click Control Panel. Click Programs. Click Turn Windows features on or off. Then set the following:*

-  Disabled -> Hyper-V
-  Enabled -> Virtual Machine Platform
-  Enabled -> Windows Hypervisor Platform
-  Disabled -> Windows Sandbox

*Then, you should also do the following. Right-click the start button, and choose PowerShell (Admin) or Command Prompt (Admin) and run the following command and reboot your machine:*

```
bcdedit /set hypervisorlaunchtype off
```

## VM name

I have tested and used the following (in descending order from favorite to installed and tested but likely would never use unless forced to):

-  MX-18.3_x64
-  MX-19_x64
-  xubuntu-20.04-desktop-amd64
-  ubuntu-mate-20.04-desktop-amd64
-  ubuntu-20.04-desktop-amd64
-  xubuntu-18.04.4-desktop-amd64
-  ubuntu-mate-18.04.4-desktop-amd64
-  ubuntu-18.04.4-desktop-amd64
-  ubuntu-19.04-desktop-amd64
-  lubuntu-18.04.4-desktop-amd64
-  kubuntu-18.04.4-desktop-amd64

I highly recommend using the name of the .iso install CD/DVD for the VM name and virtual disk for simplicity, consistency and pure laziness. Example:

```DOS .bat
SET VM=MX-19_x64
```

## Create VM and Launch Installer

Tailor to your personal environment. For most of my host computers 2 CPUs and 4G of memory is sufficient minimal virtual hardware. Again the VM name is used for .iso install DVD, virtual disk for simplicity/laziness.

### Video

`%VB% modifyvm "%VM%" --vram 128 --monitorcount 1 --graphicscontroller vmsvga --accelerate3d off --audio dsound --audiocontroller ac97 --audiocodec ad1980 --usb on --usbehci on`

As of VirtualBox version 6, I have found the vmsvga graphics controller with 3-D acceleration off to be the best performing settings for most use cases on a Windows host.

Of course, this may differ on a Linux host and most experts recommend using the VirtualBox vboxsvga graphics controller. But for Linux virtual machines the graphics settings below seem to work best after the VirtualBox guest additions have been installed.
I tried playing YouTube music and videos and playing the old Maelstrom video game to test performance and stability.
If anyone has recommendations for setup please share them.

Again, test and tailor to your needs.

If you like to play very modern games you probably do not want to do things like this in a virtual machine; you probably want a super fancy mega-gaming computer rig and everything else would be running as a virtual machine.

### Install Media

`%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\%VM%.iso"`

Using the name of the .iso install CD/DVD for the VM name makes this very simple... ( ??? )

### Virtual Hard Disk

`%VB% createhd --filename "%BF%\%VM%\%VM%.vdi" --size 80000`
`%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%BF%\%VM%\%VM%.vdi" --mtype normal`

Using the name of the .iso install CD/DVD for the VM name and the name of the virtual disk again makes this very simple... ( ??? )

### Shared Folders

I use three folders on the host to share with one or more virtual machines:

* home - contains user profile images, keepass databases, bookmarks and sub-folders for desktop wallpaper
* temp - a SSD for shared host and VM temporary items like videos to edit, assemble and process
* download - a central place to download crap or use downloaded crap

### Install

```DOS .bat
SET VG=Desktops
SET BF=%VDID%\%VG%
%VB% createvm --name "%VM%" --groups "/Desktops" --ostype Ubuntu_64 --register
%VB% modifyvm "%VM%" --snapshotfolder default --clipboard bidirectional --draganddrop hosttoguest
%VB% modifyvm "%VM%" --memory 4096 --boot1 dvd --boot2 disk --boot3 none --boot4 none --chipset piix3 --ioapic on --firmware bios --rtcuseutc on
%VB% modifyvm "%VM%" --cpus 2 --cpuhotplug on --cpuexecutioncap 100 --pae on --nested-hw-virt on
%VB% modifyvm "%VM%" --paravirtprovider kvm --hwvirtex on --nestedpaging on
%VB% modifyvm "%VM%" --vram 256 --monitorcount 1 --graphicscontroller vmsvga --accelerate3d on --audio dsound --audiocontroller ac97 --audiocodec ad1980 --usb on --usbehci on
%VB% modifyvm "%VM%" --nic1 bridged --cableconnected1 on --nictype1 virtio --bridgeadapter1 "%VNIC%"
%VB% storagectl "%VM%" --name "IDE" --add ide --controller PIIX4 --hostiocache on --bootable on
%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\%VM%.iso"
%VB% storagectl "%VM%" --name "SATA" --add sata --controller IntelAhci --portcount 6 --hostiocache off --bootable on
%VB% createhd --filename "%BF%\%VM%\%VM%.vdi" --size 80000
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%BF%\%VM%\%VM%.vdi" --mtype normal
%VB% sharedfolder add "%VM%" --name "home" --hostpath "S:\Homes" --automount
%VB% sharedfolder add "%VM%" --name "temp" --hostpath "S:\Temp" --automount
%VB% sharedfolder add "%VM%" --name "download" --hostpath "T:\Users\Joel\Downloads" --automount
%VB% startvm "%VM%"
```

Immediately maximize the VM window when started; most installers will detect the window resolution making the install easier. Some installers do not and you have to tab blindly on some dialog boxes larger than the default SVGA resolution.

I use most defaults since I am just screwing around. I use LVM if offered when paritioning.

## Post Install

### Post Install - Part 1

Disable TLP - Disable TLP power management because it is generally not effective to run a power management tool inside a virtual machine; use your host's power management settings.

``` Bash
vi /etc/default/tlp
TLP_ENABLE=0
:x
```

### Post Install - Part 2 - Install Guest Additions

There are two options: install guest additions from the OS repository or use the Oracle VirtualBox binaries from the CD - I chose Oracle binaries.

To use the repository; more than likely the installer detected it was running in a VM and these packages are already installed but if not:

``` Bash
sudo apt install -y virtualbox-guest-dkms virtualbox-guest-x11 virtualbox-guest-utils
sudo shutdown -h now; exit
```

To install Oracle VirtualBox Guest Additions

``` Bash
cd ~
sudo apt install -y build-essential module-assistant
sudo m-a prepare
cat > vbox << FOOD
cd /media/\${USER}/VBOX*
sudo ./VBoxLinuxAdditions.run
sudo shutdown -h now
FOOD
. vbox
```

Might be a good time to take a snapshot after shutdown if really screwing around. Don't forget to delete any snapshots later in the process.

### Post Install - Part 3 - Desktop goodies

These are only recommendations. If you use a central server most of the below can be stored there.
Also, if you use an apt-cache I have not figured out how to use secured (i.e. https) repositories; changing them to non secure (i.e. http) works for everything I have tested.

``` Bash
apt install keepassx rar
echo Software via apt after adding external repository
cd ~/Downloads

echo Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt update
sudo apt install -y google-chrome-stable
sudo rm /etc/apt/sources.list.d/google.list

echo Opera
wget -q -O - http://deb.opera.com/archive.key | sudo apt-key add -
sudo sh -c 'echo "deb http://deb.opera.com/opera-stable/ stable non-free" >> /etc/apt/sources.list.d/opera.list'
sudo apt update
sudo apt install -y opera-stable

echo Vivaldi
wget -Oidlaviv https://vivaldi.com/download/
wget -N `sed -e '/amd64.deb/!d;s/.*href="//;s/".*//' idlaviv`
rm idlaviv
sudo dpkg -i *.deb
rm *.deb

sudo apt install -y firefox fonts-lyx
echo Multimedia
sudo apt install -y faac faad ffmpeg2theora flac icedax id3v2 lame mencoder mpeg2dec mpeg3-utils mpegdemux mpg123 mpg321 vlc vorbis-tools
echo Image editing
sudo apt install -y blender gimp-plugin-registry geeqie
echo Video Editing
sudo apt install -y pitivi
echo Games
sudo apt install -y maelstrom
```

### Post Install - Part 4 - Users

The final installations step is to create other users that could be using this virtual machine.
Assuming the installer and administrator is already defined (i.e. me... joel...) and users needs added to the group that can use VB shared folders.
Scripting can also be used to create users and add them to the same VB group.

```
sudo usermod -a -G vboxsf joel
for FOO in mom dad spouse crazyaunt creepyuncle goodtwin eviltwin smartkid dumbkid
do
sudo adduser ${FOO}
sudo usermod -aG vboxsf ${FOO}
sudo cp -a /etc/skel/.[!.]* /home/${FOO}
sudo chown -R ${FOO}:${FOO} /home/${FOO}
done
sudo shutdown -r now
```

## Finishing up the VM

If you do not care about the version/flavor of Linux you just installed stop now. There is really nothing left to do.
However, if you wish to use the virtual machine as a quarantined "computer" or for "experts" browsing questionable Internet sites (i.e. all of them) then some extra steps could be performed to optimize things:

*  Setup profile pictures, wallpaper, application defaults, etc. for each user
*  Setup common items like start screen wallpaper, etc.
*  If you use both HDD and SDD, clean up and compress the virtual disk then relocate it to fast SSD and perform a snapshot

### SSD Optimization

If you are using pure SSD, have a tiered or hybrid SSD/HD solution (HyperDuo, Windows Storage Spaces, bcache, ZFS) then you can ignore this step.

This step compresses the virtual disk then clones it to SSD before taking a snapshot. This should keep reads on the fast SSD (while lowering writes that over long periods of time lead to SSD failure; supposedly) and keeps updated blocks on disk.
The snapshot can be deleted, disk compressed, and snapshot re-taken periodically. This also speeds the backup process as the virtual disk on SSD will be sent to backup medium once and the (much smaller) snapshot will be updated over time.

```DOS .bat
%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\gparted-live-1.0.0-5-i686.iso"
%VB% startvm "%VM%"
```

This step boots to GParted. Choose defaults until GUI versus command line and choose "2" for command prompt.

Use zerofree to zero blocks on the virtual disk for compression. The command varies due to the partitioning setup used (LVM or disk) and version (LVM) but usually something like the following:

-  LVM: zerofree -v /dev/mapper/?-?
-  ext4: zerofree -v /dev/sda1

Shutdown when complete. Gparted usually removes the "CD" for you.

```DOS .bat
DIR "%BF%\%VM%"
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium none
%VB% modifyhd --compact "%BF%\%VM%\%VM%.vdi"
DIR "%BF%\%VM%"
%VB% clonehd "%BF%\%VM%\%VM%.vdi" "%VSSD%\%VM%.vdi" --format VDI
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%VSSD%\%VM%.vdi" --mtype normal
%VB% closemedium disk "%BF%\%VM%\%VM%.vdi"
del "%BF%\%VM%\%VM%.vdi"
%VB% snapshot "%VM%" take "BASE" --description "Freezes .VDI to SSD leaving differencing disks on HDD drives"
```

# Resources

-  [Oracle VM VirtualBox 6.0: 3D Acceleration for Ubuntu 18.04 Guest | Oracle Simon Coter Blog](https://blogs.oracle.com/scoter/oracle-vm-virtualbox-6-3d-acceleration-for-ubuntu-1804-guest)
