# Ubuntu Mini BASE

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

## Purpose

Create a bare minimum Ubuntu image in VirtualBox to use as a template for all VirtualBox labs, test scenarios, etc.

## Create VM
```
SET VM=UBU1804MINI
SET VG=Templates
SET BF=%VDID%\%VG%
%VB% createvm --name "%VM%" --groups "/Templates" --ostype Ubuntu_64 --register
%VB% modifyvm "%VM%" --snapshotfolder default --clipboard bidirectional --draganddrop hosttoguest
%VB% modifyvm "%VM%" --memory 2048 --boot1 dvd --boot2 disk --boot3 none --boot4 none --firmware bios --chipset piix3 --acpi on --ioapic on --rtcuseutc on --cpus 2 --cpuhotplug on --cpuexecutioncap 100 --pae on --paravirtprovider kvm --hpet on --hwvirtex on --nestedpaging on
%VB% modifyvm "%VM%" --vram 16 --monitorcount 1 --accelerate3d off --audio none --usb on --usbehci on
%VB% modifyvm "%VM%" --nic1 bridged --cableconnected1 on --nictype1 virtio --bridgeadapter1 "%VNIC%"
%VB% storagectl "%VM%" --name "IDE" --add ide --controller PIIX4 --hostiocache on --bootable on
%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\ubuntu-18.04-mini-amd64.iso"
%VB% storagectl "%VM%" --name "SATA" --add sata --controller IntelAhci --portcount 6 --hostiocache off --bootable on
%VB% createhd --filename "%BF%\%VM%\%VM%_ROOT.vdi" --size 120000
%VB% createhd --filename "%BF%\%VM%\%VM%_TEMP.vdi" --size 32000
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%BF%\%VM%\%VM%_ROOT.vdi" --mtype normal
%VB% storageattach "%VM%" --storagectl "SATA" --port 1 --type hdd --medium "%BF%\%VM%\%VM%_TEMP.vdi" --mtype normal
%VB% startvm "%VM%"
```
Use all defaults using LVM and host name ubu1804mini. 

## Finish VM

```
%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\gparted-live-0.33.0-1-i686.iso"
%VB% startvm "%VM%"
```

Select defaults then command prompt then do the following:

```Shell
zerofree -v /dev/mapper/UBU18042--vg-root
shutdown -h now
```

The CD image will be automatically unmounted so it does not need to be removed from the virtual machine at the command prompt. The steps below will detach the virtual disk, compacted then clone it to SSD for optimal performance and space usage and creative a snapshot for all other virtual machines. Obviously, this a specific to my workstations and may not be applicable to your situation.

```
DIR "%BF%\%VM%"
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium none
%VB% modifyhd --compact "%BF%\%VM%\%VM%.vdi"
DIR "%BF%\%VM%"
%VB% clonehd "%BF%\%VM%\%VM%.vdi" "%VSSD%\%VM%.vdi" --format VDI
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%VSSD%\%VM%.vdi" --mtype normal
%VB% closemedium disk "%BF%\%VM%\%VM%.vdi"
del "%BF%\%VM%\%VM%.vdi"
%VB% snapshot "%VM%" take "BASE" --description "Freezes .VDI to SSD leaving differencing disks on drives"
```

If you backup your virtual machines that would be a good time to do so.