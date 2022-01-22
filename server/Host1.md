#

## Installation
## Hardening
## Storage

### Layout



1.  Docker - BTRFS
2.  Docker - BTRFS, standard compression LZO
3.  Docker - BTRFS, highest compression ZSTD
4.  Data
5.  SnapRAID Parity
6.  SnapRAID Parity
7.  reserved
8.  reserved
9.  reserved
10. reserved
11. SnapRAID content file, Data
12. SnapRAID content file, Data
13. Data
14. Data
15. Data
16. Data
17. Data
18. Data
19. Data
20. Data
21. Data
22. Data
23. Data
24. Data


UUID=c631c0e2-9f7b-44ba-b96e-fadc9299f85e /               btrfs   defaults,discard,noatime,subvol=@ 0       1
UUID=09D7-AB91  /boot/efi       vfat    umask=0077      0       1
UUID=c631c0e2-9f7b-44ba-b96e-fadc9299f85e /home           btrfs   defaults,discard,noatime,nodev,nosuid,subvol=@home 0       2
UUID=0983be77-c35e-43dc-baec-05d1175055e8 /tmp2           ext4    defaults,discard,noatime,nodev,nosuid        0       2
UUID=bfe127a4-b2c2-4395-800d-4aa58048e3cb none            swap    sw              0       0
UUID=c631c0e2-9f7b-44ba-b96e-fadc9299f85e /var   btrfs   defaults,discard,noatime,subvol=@var,nodatacow 0 1
UUID=c631c0e2-9f7b-44ba-b96e-fadc9299f85e /var/log   btrfs   defaults,discard,noatime,subvol=@var-log,compress,nosuid,nodev,noexec 0 1
UUID=c631c0e2-9f7b-44ba-b96e-fadc9299f85e /var/log/audit   btrfs   defaults,discard,noatime,subvol=@var-audit,compress,nosuid,nodev,noexec 0 2
UUID=c631c0e2-9f7b-44ba-b96e-fadc9299f85e /var/tmp   btrfs   defaults,discard,noatime,subvol=@var-tmp,nosuid,nodev,noexec 0 2

#### Docker
UUID=fb0af4dd-8db6-499c-b470-6ce549991467 /var/lib/docker  btrfs  defaults,discard,noatime,subvol=@docker 0 1
UUID=fb0af4dd-8db6-499c-b470-6ce549991467 /srv/u01         btrfs  defaults,discard,noatime,subvol=@u01    0 2
UUID=fb0af4dd-8db6-499c-b470-6ce549991467 /srv/u02         btrfs  defaults,compress=lzo,discard,noatime,subvol=@u02    0 2
UUID=fb0af4dd-8db6-499c-b470-6ce549991467 /srv/u03         btrfs  defaults,compress=zstd:15,discard,noatime,subvol=@u03    0 2

#### Hardening
none /run/shm tmpfs rw,noexec,nosuid,nodev 0 0
none /dev/shm tmpfs rw,noexec,nosuid,nodev 0 0
none /proc proc rw,nosuid,nodev,noexec,relatime,hidepid=2 0 0

#### SnapRAID Parity Disks
2TB virtual disks, tier 3 storage

/srv/u05  ext4
/srv/u06  ext4

#### Data Disks

2TB virtual disks unless otherwise noted

- /srv/u04  ext4 - tier 3, not in SnapRAID - downloads and temporary media
- /srv/u11  ext4 - bcache 20GB + 2TB tier 2 - media
- /srv/u12  ext4 - bcache 20GB + 2TB tier 2 - media
- /srv/u13  ext4 - bcache 10GB + tier 4 - archived media
- /srv/u14  ext4 - 1 TB - tier 4 - archived media
- /srv/u15  ext4 - tier 4 - chia
- /srv/u16  ext4 - tier 4 - chia
- /srv/u17  ext4 - tier 4 - chia
- /srv/u18  ext4 - tier 4 - chia
- /srv/u19  ext4 - tier 4 - chia
- /srv/u20  ext4 - tier 4 - chia
- /srv/u21  ext4 - tier 4 - media
- /srv/u22  ext4 - tier 4 - media
- /srv/u23  ext4 - tier 4 - media
- /srv/u24  ext4 - tier 4 - media




## Docker
## Backup and Recovery
## References

