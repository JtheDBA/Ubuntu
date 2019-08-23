


## Before Creating the VM

Since the purpose of this virtual machine is to live on a physical system containing files and services outside the virtual machine we should perform a few things before continuing:

1.  create a download folder on the host
2.  download the base `ubuntu-18.04-mini-amd64.iso` Ubuntu Mini image and `gparted-live-0.33.0-1-i686.iso` GParted image (for virtual disk optimization)

I created a download shared folder on the host for our home network. This folder will contain all software and disk images. Since this share can be rebuilt I do not include it in any backups on the host. All Windows and Linux physical computers mount this location locally so it can be used as a centralized folder for all software.

## QEMU (and KVM)

This has been tested and operational for:

-  Ubuntu 18.04 Server on Synology DS-218+ in Virtual Machine Manager



```Shell
sudo -i
add-apt-repository universe
apt update
apt install -y qemu-guest-agent
```

## HyperV on Server 2016

Primary References

-  (https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v)
-  (https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v)

Create VM

```PowerShell
New-VHD -Path 'V:\Virtual Hard Disks\UBU1804.vhdx' -SizeBytes 127GB -Dynamic -BlockSizeBytes 1MB
```

- Secure Boot disabled
- Memory
- Using dynamic memory with start of memory at 2 GB, minimum RAM at 1 GB, maximum RAM at 4 GB and defaults for the rest
- Processor
- Two virtual processors with defaults

```Shell
sudo -i
add-apt-repository universe
apt update
apt install -y linux-azure
```

## VMWare ESX 6.7 U2

References

-  (https://www.vmware.com/resources/compatibility/search.php?b=1564619716893)
-  (http://partnerweb.vmware.com/GOSIG/Ubuntu_18_04_LTS.html)

Network VMXNET 3: Supported (Recommended)
Storage
IDE:	Supported	Virtual IDE adapter for ATA disks ? required for CDROM ???
VMware Paravirtual:	Supported (Recommended)	VMware Paravirtual SCSI (PVSCSI) adapter

```Shell
sudo -i
apt update
apt install -y open-vm-tools
```


apt install -y apt-cacher-ng cifs-utils deborphan libcups2 lynx mc nfs-common p7zip-full p7zip-rar rar samba-common tree unzip zip zsync