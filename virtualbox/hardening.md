```
SET VM=UBU2004 konstruktoid
SET VG=Ubuntu Hardening GitHub
SET BF=%VDID%\%VG%
%VB% createvm --name "%VM%" --groups "/Templates" --ostype Ubuntu_64 --register
%VB% modifyvm "%VM%" --snapshotfolder default --clipboard bidirectional --draganddrop hosttoguest
%VB% modifyvm "%VM%" --memory 2048 --boot1 dvd --boot2 disk --boot3 none --boot4 none --firmware bios --chipset piix3 --acpi on --ioapic on --rtcuseutc on --cpus 2 --cpuhotplug on --cpuexecutioncap 100 --pae on --paravirtprovider kvm --hpet on --hwvirtex on --nestedpaging on
%VB% modifyvm "%VM%" --vram 16 --monitorcount 1 --accelerate3d off --audio none --usb on --usbehci on
%VB% modifyvm "%VM%" --nic1 bridged --cableconnected1 on --nictype1 virtio --bridgeadapter1 "%VNIC%"
%VB% storagectl "%VM%" --name "IDE" --add ide --controller PIIX4 --hostiocache on --bootable on
%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\ubuntu-20.04.1-live-server-amd64.iso"
%VB% storagectl "%VM%" --name "SATA" --add sata --controller IntelAhci --portcount 6 --hostiocache off --bootable on
%VB% createhd --filename "%BF%\%VM%\%VM%_ROOT.vdi" --size 120000
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%BF%\%VM%\%VM%_ROOT.vdi" --mtype normal
%VB% startvm "%VM%"
```

```
%VB% storageattach "%VM%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%VISO%\gparted-live-1.0.0-5-amd64.iso"
%VB% startvm "%VM%"
```

```
DIR "%BF%\%VM%"
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium none
%VB% modifyhd --compact "%BF%\%VM%\%VM%_ROOT.vdi"
DIR "%BF%\%VM%"
%VB% clonehd "%BF%\%VM%\%VM%_ROOT.vdi" "%VSSD%\%VM%_ROOT.vdi" --format VDI
%VB% storageattach "%VM%" --storagectl "SATA" --port 0 --type hdd --medium "%VSSD%\%VM%_ROOT.vdi" --mtype normal
%VB% closemedium disk "%BF%\%VM%\%VM%_ROOT.vdi"
del "%BF%\%VM%\%VM%_ROOT.vdi"
%VB% snapshot "%VM%" take "?" --description "Freezes .VDI to SSD leaving differencing disks on HDD drives"
```
