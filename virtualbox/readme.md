# Virtual Box

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

I use Virtual Box as my primary goofing around at home virtualization product.

-  [Download Oracle VM VirtualBox](https://www.oracle.com/virtualization/technologies/vm/downloads/virtualbox-downloads.html)
-  [Pre-Built Developer VMs](https://www.oracle.com/downloads/developer-vm/community-downloads.html)
-  [vagrant-boxes](https://github.com/oracle/vagrant-boxes) - [Vagrant](https://vagrantup.com/) builds for Oracle products and other examples

## Command Prompt / Shell

I prefer to do work for now from the command line versus using a GUI. And yes, I fully realize [Vagrant](https://vagrantup.com/) exists along with other rapid/standard software applications. This, is how I learn for now.

### Variables

-  VB - path to the VBoxManage executable file
-  VDID - path to the root directory where virtual machines, virtual disks and snapshots are located on hard disk
-  VISO - path to where .iso images are located
-  VNIC - the name of your network interface
-  VSSD - path to the root directory on SSD where base images of virtual hard disks can be located
-  VM - Name of the VM
-  VG - Group Name within Virtual Box
-  BF - Base folder, a combination of VDID plus VG

### vb

Run this script one from the prompt to set up all common variables.

`vb.cmd`

```DOS .bat
SET VB="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
SET VDID=H:\VirtualBox VMs
SET VISO=I:
SET VSSD=S:\VirtualBox VMs
SET VNIC=Realtek PCIe GBE Family Controller
```

### vbupd

TODO

### vbbkp

TODO
