# home

This directory actually contains two things. First it contains the subdirectories loaded into your system administrator's i.e. `sadmin` directory on a centralized server for easy installation of desktops and servers on physical or virtual machines.
It is also a location for how to build a central server for your home with all of the above plus media servers, file servers, music servers, etc.

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

## home (The Directory)

-  sadmin
   -  ansible - Ansible playbooks and other goodies
   -  common - three common files used in almost all other sub directories via symbolic link
   -  desktop - files used automate the installation of software on Ubuntu desktops
   -  hyperv - files used on a Hyper-V virtual machine
   -  kvm - files used on a KVM virtual machine
   -  lxc - files used within a LXD container
   -  server - files used on servers to automate  most basic preparatory an update steps
   -  vbox - files used in a virtual box virtual machine
   -  wsl - files used in a Windows subsystem for Linux Ubuntu installation


## Home Server

   - [Building an Ubuntu Home Server](UbuntuHomeServer.md)

