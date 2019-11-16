# Ubuntu Server 18.04 Virtual Install

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

## Before Creating the VM

I recommend obtaining the following .iso images before installing

-  `ubuntu-18.04-mini-amd64.iso` Ubuntu Mini image
-  `gparted-live-0.33.0-1-i686.iso` GParted image (for virtual disk optimization post installation)

## Steps

1.  obtain installation media
2.  follow host specific steps below to **Create VM**
3.  follow host specific steps below **Post Installation**
4.  install OS based on first steps for [BTRFS](Ubuntu Server 18.04 BTRFS Secure.md)
5.  follow host specific steps below **VM Optimization**

# QEMU (and KVM)

This has been tested and operational for:

-  Ubuntu 18.04 Server on Synology DS-218+ in Virtual Machine Manager

## Post Installation

```Shell
sudo add-apt-repository universe
sudo apt update
sudo apt install -y qemu-guest-agent
sudo shutdown -r 1; exit
```

# HyperV on Server 2016

Primary References

-  (https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v)
-  (https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v)

## Create VM

1.  run PowerShell as Administrator
2.  set some basic variables
3.  create a new VM attached to the home LAN virtual switch
4.  disable secure boot
5.  create virtual disks and attach to the SCSI controller (used arrays for flexibility? 6 vs 4 lines why not?)
6.  determine the location of the Ubuntu mini .iso and attach it
7.  enable dynamic memory and set minimum and maximum memory
8.  enable guest service interface integration services
9.  start the VM

```PowerShell
$vmmPath = 'V:\Hyper-V\'
$vddPath = 'V:\Virtual Hard Disks\'
$vdiPath = 'M:\Shared\Software\'
$vm = "Ubuntu 18.04 Server"

New-VM -MemoryStartupBytes 1024MB -Name $vm -Path $vmmPath -Generation 2 -SwitchName 'vSwitch External Home LAN'

Set-VMFirmware $vm -EnableSecureBoot Off
foreach ($disk in @(0,1)) {
    $vhdx = $vddPath + "UBU1804S" + $disk +".vhdx"
    $vsgb = @(128GB,16GB)[$disk]
    New-VHD -Path $vhdx -SizeBytes $vsgb -Dynamic -BlockSizeBytes 1MB 
    Add-VMHardDiskDrive -VMName $vm -Path $vhdx -ControllerType SCSI -ControllerNumber 0 -ControllerLocation $disk
}
$iSO = Get-ChildItem -Path $vdiPath -Filter 'ubuntu*mini-amd64.iso'
Add-VMDvdDrive -VMName $vm -Path $iSO.FullName -ControllerNumber 0 -ControllerLocation 2

Set-VMMemory -VMName $vm -DynamicMemoryEnabled $true -MinimumBytes 512MB -MaximumBytes 4GB
Enable-VMIntegrationService -VMName $vm -Name 'Guest Service Interface'
Start-VM -Name $vm

<# If DVD needs to be dismounted
Set-VMDvdDrive -VMName $vm -Path $null -ControllerNumber 0 -ControllerLocation 2
#>
```

## Post Installation

Install the linux-azure kernel

```Shell
sudo add-apt-repository universe
sudo apt update
sudo apt install -y linux-azure
sudo shutdown -r 1
```

## VM Optimization

If the BTRFS steps were used to install the file system optimization is not needed and can be skipped. Remove media from drive and take a checkpoint.

```PowerShell
Set-VMDvdDrive -VMName $vm -Path $null -ControllerNumber 0 -ControllerLocation 2
Checkpoint-VM -Name $vm -SnapshotName 'BASE01'
Start-VM -Name $vm
```

# VMWare ESX 6.7 U2

References

-  (https://www.vmware.com/resources/compatibility/search.php?b=1564619716893)
-  (http://partnerweb.vmware.com/GOSIG/Ubuntu_18_04_LTS.html)

Network VMXNET 3: Supported (Recommended)
Storage
IDE:	Supported	Virtual IDE adapter for ATA disks ? required for CDROM ???
VMware Paravirtual:	Supported (Recommended)	VMware Paravirtual SCSI (PVSCSI) adapter

### Post Installation

```Shell
sudo -i
apt update
apt install -y open-vm-tools
```
