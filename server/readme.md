# Ubuntu Server 20.04

## Notes

There is a brand-new installer with the 20.04 release of Ubuntu. It is my opinion the new direction is a move toward a standard but less flexible deployment for this distribution. 

I initially went down the path of looking at automated installations through the Ubiquity installer using information from message boards and the Discord conversations on the specific topic. In my opinion, there are no straightforward options available that appear consistent through the occasional minor or less frequent major update of Ubuntu. Using VirtualBox I have followed along with the frustrations of many to try to get things to work consistently. It is my opinion this technology is not 100% ready for a realistic production environment.

I have chosen the following:

-  install Ubuntu using the minimal or cloud image; the unit of installation that appears to be replacing the Ubuntu Mini installation from 18.04
-  I'm still using BTRFS for the root disk; even though the BTRFS technology is not considered fully production stable other distributions are using BTRFS as a default in my opinion it is a worthwhile direction
-  I separate temporary disk to a second disk; this is for DR solutions and how they handle temporary virtual disks
-  I still harden the BTRFS file system after the installation using information from konstruktoid/hardening



