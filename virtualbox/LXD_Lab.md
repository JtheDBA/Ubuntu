# LXD Lab

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*
-  *This can probably be done with Chef or insert automation tool here but I are learnding...*

## Clone the Base Ubuntu Server

```DOS .bat
SET VM=Ubuntu Server 18.04 LXD ZFS
SET VG=Server Templates
SET BF=%VDID%\%VG%
%VB% clonevm "Ubuntu Server 18.04 BTRFS Secure EFI64" --snapshot "BASE2001" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
%VB% modifyvm "%VM%" --memory 4096
%VB% modifyvm "%VM%" --nic2 bridged --cableconnected2 on --nictype2 virtio --bridgeadapter2 "%VNIC%" --nicpromisc2 allow-all
%VB% createhd --filename "%VSSD%\UBU1804_LXDZFS_SATA2.vdi" --size 120002
%VB% createhd --filename "%VSSD%\UBU1804_LXDZFS_SATA3.vdi" --size 120003
%VB% createhd --filename "%VSSD%\UBU1804_LXDZFS_SATA4.vdi" --size 8004
%VB% storageattach "%VM%" --storagectl "SATA" --port 2 --type hdd --medium "%VSSD%\UBU1804_LXDZFS_SATA2.vdi" --mtype normal
%VB% storageattach "%VM%" --storagectl "SATA" --port 3 --type hdd --medium "%VSSD%\UBU1804_LXDZFS_SATA3.vdi" --mtype normal
%VB% storageattach "%VM%" --storagectl "SATA" --port 4 --type hdd --nonrotational on --medium "%VSSD%\UBU1804_LXDZFS_SATA4.vdi" --mtype normal
%VB% startvm "%VM%"
```

## Prepare LXD Standalone and BASE Snapshot for Cluster Nodes

I love doing everything through copy and paste via PuTTY: `"C:\Program Files (x86)\PuTTY\putty.exe" sadmin@192.168.0.?`

Set the host name, get everything from the central server (if you haven't) then run the prepare step.

```Bash
sudo -i
OLDHO=`cat /etc/hostname`
NEWHO=ubu1804-lxd
hostnamectl set-hostname ${NEWHO}
sed -i -e "s/${OLDHO}/${NEWHO}/' /etc/hosts
scp 192.168.0.184:server/lxd*
```

The next steps depend upon the backing file system you choose: ZFS (recommended ???) or BTRFS (no official recommendation)

## ZFS

Run `lxd.zfs.prep1` - the preparation script will restart your computer!

Run `lxd.zfs.prep2` - this will list the unique identifiers for each disk and partition on your machine and print the basic shell for creating a ZFS pool, adding a SLOG, and creating a dataset to use for LXD.
Obviously this could be scripted but, why..? 

Run one of the following:
  - `lxd.init.zfs.standalone`
  - `lxd.init.zfs.node1` - first node in a cluster
  - `lxd.init.zfs.nodes` - other nodes in the cluster

## BTRFS

Run `lxd.btrfs.prep1` - the preparation script will restart your computer!

Run `lxd.btrfs.prep2` - 

Run one of the following:
  - `lxd.init.btrfs.standalone`
  - `lxd.init.btrfs.node1` - first node in a cluster
  - `lxd.init.btrfs.nodes` - other nodes in the cluster

# Ignore EVERYTHING Beyond This Point
  

```Bash
sudo -i
OLDHO=`cat /etc/hostname`
NEWHO=ubu1804-lxd
hostnamectl set-hostname ${NEWHO}
sed -i -e "s/${OLDHO}/${NEWHO}/' /etc/hosts
scp 192.168.0.184:server/lxd*
. lxd.prep
```

apt-get purge -y lxd lxd-client
apt-get install -y bridge-utils zfsutils-linux
snap install lxd

cat > 01-netcfg.yaml << FOOD
This file describes the network interfaces available on your system
For more information, see netplan(5).
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [192.168.0.20X/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
      optional: false
    enp0s8:
      dhcp4: no
      addresses: [192.168.0.23X/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
      optional: false
FOOD
cat > lxdinit-single << FOOD
config:
  core.trust_password: C7uster
  core.https_address: 192.168.0.200:8443
  images.auto_update_interval: 15
storage_pools:
- name: local
  description: "local ZFS Pool"
  driver: zfs
  source: /dev/sdb
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: 192.168.200.1/24
    ipv6.address: none
profiles:
- name: default
  devices:
    root:
      path: /
      pool: local
      type: disk
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
FOOD
sed -e 's/200/201/' lxdinit-single > lxdinit-node1
cat >> lxdinit-node1 << FOOD
cluster:
  enabled: true
  server_name: node1
FOOD
cat > step01 << FOOD
./updhost ubulxd?
sed -e 's/2\(.\)X/2\1?/' 01-netcfg.yaml > /etc/netplan/01-netcfg.yaml
reboot
FOOD

reboot

. updone
```

## Snapshot and Create Lab Linked Clones

Take a snapshot for the next steps,

```
%VB% snapshot "%VM%" take "BASE" --description "Base for linked clones"
%VB% showvminfo "%VM%"
SET VG=Ubuntu LXD Lab
SET BF=%VDID%\%VG%
FOR %A IN (Node1 Node2 Node3) DO %VB% clonevm "Ubuntu Server 18.04 LXD ZFS" --snapshot "BASE" --options link --name "Ubuntu LXD %A" --basefolder "%VDID%" --register
FOR %A IN (Node1 Node2 Node3) DO %VB% modifyvm "Ubuntu LXD %A" --groups "/%VG%"

```

# Standalone LXD


# Clustered LXD


cluster:
  server_name: ubulxd2
  enabled: true
  member_config:
  - entity: storage-pool
    name: local
    key: size
    value: ""
    description: '"size" property for storage pool "local"'
  - entity: storage-pool
    name: local
    key: source
    value: ""
    description: '"source" property for storage pool "local"'
  - entity: storage-pool
    name: local
    key: zfs.pool_name
    value: ""
    description: '"zfs.pool_name" property for storage pool "local"'
  cluster_address: 192.168.0.201:8443
  cluster_certificate: |
    -----BEGIN CERTIFICATE-----
    MIIB/DCCAYGgAwIBAgIRAIl557FebTZukZ9i/x5kMI4wCgYIKoZIzj0EAwMwNTEc
    MBoGA1UEChMTbGludXhjb250YWluZXJzLm9yZzEVMBMGA1UEAwwMcm9vdEB1YnVs
    eGQxMB4XDTE5MDgyNjIxNTcyM1oXDTI5MDgyMzIxNTcyM1owNTEcMBoGA1UEChMT
    bGludXhjb250YWluZXJzLm9yZzEVMBMGA1UEAwwMcm9vdEB1YnVseGQxMHYwEAYH
    KoZIzj0CAQYFK4EEACIDYgAEgwHN1QrLp/PslnEVBcjsTqgugOH+gqjnEa1dM1Le
    1xmoH/zw69327R8yBK2Q9Qtf1kUu9RuAziSVkHU68cA6WiCHaXcOInmOFMoTkgZM
    +TWxuY5nfsxwFb9HjYQLluSko1UwUzAOBgNVHQ8BAf8EBAMCBaAwEwYDVR0lBAww
    CgYIKwYBBQUHAwEwDAYDVR0TAQH/BAIwADAeBgNVHREEFzAVggd1YnVseGQxhwTA
    qADJhwTAqADnMAoGCCqGSM49BAMDA2kAMGYCMQDIiaFalEITY1nVOBaUoqkNWqa5
    NG07PCj4tclsT1t/1FbghcKQ6DnhY1qJAx891K4CMQChVqMa1aVgnn7NBisVcoT/
    iw3HWPnFz2FcyJssid0htnjWmIrPSn1YFt1EZcs6U1w=
    -----END CERTIFICATE-----
  server_address: 192.168.0.202:8443
  cluster_password: C7uster




cluster:
  enabled: true
  server_name: node2
  server_address: 10.55.60.155:8443
  cluster_address: 10.55.60.171:8443
  cluster_certificate: "-----BEGIN CERTIFICATE-----

opyQ1VRpAg2sV2C4W8irbNqeUsTeZZxhLqp4vNOXXBBrSqUCdPu1JXADV0kavg1l

2sXYoMobyV3K+RaJgsr1OiHjacGiGCQT3YyNGGY/n5zgT/8xI0Dquvja0bNkaf6f

...

-----END CERTIFICATE-----
"
  cluster_password: sekret
  member_config:
  - entity: storage-pool
    name: default
    key: source
    value: ""


```
for Q in 2 3
do
sed -e "s/node1/node${Q}/;/storage_pools/,/ipv6/d;s/201/20${Q}/" lxdinit-node1 > lxdinit-node${Q}
echo "  server_address: 192.168.0.20${Q}" >> lxdinit-node${Q}
sed -e '/https_address/!d;s/core.https_address/cluster_address/' lxdinit-node1 >> lxdinit-node${Q}
lxc info | sed -e '1,/certificate:/d;/certificate_fingerprint/,$d;s/    -----B/    cluster_certificate: "-----B/;s/    //' >> lxdinit-node${Q}
cat >> lxdinit-node${Q} << FOOD
"
  cluster_password: sekret
  member_config:
  - entity: storage-pool
    name: default
    key: source
    value: ""
FOOD
done


```

config: {}
networks: []
storage_pools: []
profiles: []
cluster:
  server_name: ubulxd2
  enabled: true
  member_config:
  - entity: storage-pool
    name: local
    key: size
    value: ""
    description: '"size" property for storage pool "local"'
  - entity: storage-pool
    name: local
    key: source
    value: ""
    description: '"source" property for storage pool "local"'
  - entity: storage-pool
    name: local
    key: zfs.pool_name
    value: ""
    description: '"zfs.pool_name" property for storage pool "local"'
  cluster_address: 192.168.0.201:8443
  cluster_certificate: |
    -----BEGIN CERTIFICATE-----
    MIIB/DCCAYGgAwIBAgIRAIl557FebTZukZ9i/x5kMI4wCgYIKoZIzj0EAwMwNTEc
    MBoGA1UEChMTbGludXhjb250YWluZXJzLm9yZzEVMBMGA1UEAwwMcm9vdEB1YnVs
    eGQxMB4XDTE5MDgyNjIxNTcyM1oXDTI5MDgyMzIxNTcyM1owNTEcMBoGA1UEChMT
    bGludXhjb250YWluZXJzLm9yZzEVMBMGA1UEAwwMcm9vdEB1YnVseGQxMHYwEAYH
    KoZIzj0CAQYFK4EEACIDYgAEgwHN1QrLp/PslnEVBcjsTqgugOH+gqjnEa1dM1Le
    1xmoH/zw69327R8yBK2Q9Qtf1kUu9RuAziSVkHU68cA6WiCHaXcOInmOFMoTkgZM
    +TWxuY5nfsxwFb9HjYQLluSko1UwUzAOBgNVHQ8BAf8EBAMCBaAwEwYDVR0lBAww
    CgYIKwYBBQUHAwEwDAYDVR0TAQH/BAIwADAeBgNVHREEFzAVggd1YnVseGQxhwTA
    qADJhwTAqADnMAoGCCqGSM49BAMDA2kAMGYCMQDIiaFalEITY1nVOBaUoqkNWqa5
    NG07PCj4tclsT1t/1FbghcKQ6DnhY1qJAx891K4CMQChVqMa1aVgnn7NBisVcoT/
    iw3HWPnFz2FcyJssid0htnjWmIrPSn1YFt1EZcs6U1w=
    -----END CERTIFICATE-----
  server_address: 192.168.0.202:8443
  cluster_password: C7uster








cat > node2 << FOOD
config:
  core.trust_password: C7uster
  core.https_address: 192.168.0.202:8443
  images.auto_update_interval: 15
profiles:
- name: default
  devices:
    root:
      path: /
      pool: local
      type: disk
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
cluster:
  server_name: ubulxd2
  enabled: true
  server_address: 192.168.0.202
  cluster_address: 192.168.0.201:8443
  cluster_certificate: |
    -----BEGIN CERTIFICATE-----
    MIIB+TCCAYCgAwIBAgIQKG5yVzOPzdNWeAHEJ6hcYDAKBggqhkjOPQQDAzA1MRww
    GgYDVQQKExNsaW51eGNvbnRhaW5lcnMub3JnMRUwEwYDVQQDDAxyb290QHVidWx4
    ZDEwHhcNMTkwODI3MDAwMTQxWhcNMjkwODI0MDAwMTQxWjA1MRwwGgYDVQQKExNs
    aW51eGNvbnRhaW5lcnMub3JnMRUwEwYDVQQDDAxyb290QHVidWx4ZDEwdjAQBgcq
    hkjOPQIBBgUrgQQAIgNiAATPdLZ+bBwdyBaMiqUPrQor8t0CzvnqjRxGouBdowkv
    ClF1PuLIr9hCrUeInah5mxae8CtNwHWK1aLRuWwdIZ0rK7UDRYe/PBHEiVpiUd4C
    ywSOieWjpuIYx3Br7+lH9EWjVTBTMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAK
    BggrBgEFBQcDATAMBgNVHRMBAf8EAjAAMB4GA1UdEQQXMBWCB3VidWx4ZDGHBMCo
    AMmHBMCoAOcwCgYIKoZIzj0EAwMDZwAwZAIwVrvEm8J6YE6Ws4LiIO8ZRwK4ZBeB
    MyoNMnAcaOr+lrmACQXHyPA1viESyi5FsLv4AjB1Dl4oUp/iI8EdQ4DLQ2SLS9z+
    AFLFZ7mRu3fJaNADRxRaXyqFIs0ZVBGvMYllLcI=
    -----END CERTIFICATE-----
  cluster_password: C7uster
  member_config:
  - entity: storage-pool
    name: local
    key: source
    value: ""
FOOD
cat node2 | sudo lxd init --preseed




joel@ubulxd1:~$ sudo lxd init
[sudo] password for joel:
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What name should be used to identify this node in the cluster? [default=ubulxd1]:
What IP address or DNS name should be used to reach this node? [default=192.168.0.201]:
Are you joining an existing cluster? (yes/no) [default=no]:
Setup password authentication on the cluster? (yes/no) [default=yes]:
Trust password for new clients:
Again:
Do you want to configure a new local storage pool? (yes/no) [default=yes]:
Name of the storage backend to use (btrfs, cephfs, dir, lvm, zfs) [default=zfs]:
Create a new ZFS pool? (yes/no) [default=yes]:
Would you like to use an existing block device? (yes/no) [default=no]: yes
Path to the existing block device: /dev/sdb
Do you want to configure a new remote storage pool? (yes/no) [default=no]:
Would you like to connect to a MAAS server? (yes/no) [default=no]:
Would you like to configure LXD to use an existing bridge or host interface? (yes/no) [default=no]:
Would you like to create a new Fan overlay network? (yes/no) [default=yes]:
What subnet should be used as the Fan underlay? [default=auto]:
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
config:
  core.https_address: 192.168.0.201:8443
  core.trust_password: C7uster
networks:
- config:
    bridge.mode: fan
    fan.underlay_subnet: auto
  description: ""
  managed: false
  name: lxdfan0
  type: ""
storage_pools:
- config:
    source: /dev/sdb
  description: ""
  name: local
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdfan0
      type: nic
    root:
      path: /
      pool: local
      type: disk
  name: default
cluster:
  server_name: ubulxd1
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""

joel@ubulxd2:~$ sudo lxd init
[sudo] password for joel:
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What name should be used to identify this node in the cluster? [default=ubulxd2]:
What IP address or DNS name should be used to reach this node? [default=192.168.0.202]:
Are you joining an existing cluster? (yes/no) [default=no]: yes
IP address or FQDN of an existing cluster node: 192.168.0.201
Cluster fingerprint: 98a0d46bdeb9e97cd265d1095dbaabc9d02384056c75c100a1614ed5ade8a705
You can validate this fingerprint by running "lxc info" locally on an existing node.
Is this the correct fingerprint? (yes/no) [default=no]: yes
Cluster trust password:
All existing data is lost when joining a cluster, continue? (yes/no) [default=no] yes
Choose "source" property for storage pool "local": /dev/sdb
Choose "zfs.pool_name" property for storage pool "local": local
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
config: {}
networks: []
storage_pools: []
profiles: []
cluster:
  server_name: ubulxd2
  enabled: true
  member_config:
  - entity: storage-pool
    name: local
    key: source
    value: /dev/sdb
    description: '"source" property for storage pool "local"'
  - entity: storage-pool
    name: local
    key: zfs.pool_name
    value: local
    description: '"zfs.pool_name" property for storage pool "local"'
  cluster_address: 192.168.0.201:8443
  cluster_certificate: |
    -----BEGIN CERTIFICATE-----
    MIIB+jCCAYCgAwIBAgIQefXGwywovTGIUgeaImmNOzAKBggqhkjOPQQDAzA1MRww
    GgYDVQQKExNsaW51eGNvbnRhaW5lcnMub3JnMRUwEwYDVQQDDAxyb290QHVidWx4
    ZDEwHhcNMTkwODI3MDA0NTUwWhcNMjkwODI0MDA0NTUwWjA1MRwwGgYDVQQKExNs
    aW51eGNvbnRhaW5lcnMub3JnMRUwEwYDVQQDDAxyb290QHVidWx4ZDEwdjAQBgcq
    hkjOPQIBBgUrgQQAIgNiAARYinCNFMZIkOs12EvI2rqJxk0G14kK91dSdsc+Gwb0
    ysfPVWfBjNIV+yi0GR3O7snjfQULZh7Jxglrk9LqeJKmsLNh5K0fLTZca/WWtMee
    cMIHRQZWqF49/5EPmCKwNSujVTBTMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAK
    BggrBgEFBQcDATAMBgNVHRMBAf8EAjAAMB4GA1UdEQQXMBWCB3VidWx4ZDGHBMCo
    AMmHBMCoAOcwCgYIKoZIzj0EAwMDaAAwZQIwEE2NGYjzV39v0xZyXqCcqvPDEsLK
    VPiIOwjxzIXm9xnEuR9eWFRGt3h4HBWyI7TWAjEAm7Yo2roaippPvK1CjmSdkmXZ
    qE71OsyhGWvC6fRvm7bs3h3vt782yiwHjm0BOmVu
    -----END CERTIFICATE-----
  server_address: 192.168.0.202:8443
  cluster_password: C7uster

joel@ubulxd3:~$ sudo lxd init
[sudo] password for joel:
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What name should be used to identify this node in the cluster? [default=ubulxd3]:
What IP address or DNS name should be used to reach this node? [default=192.168.0.203]:
Are you joining an existing cluster? (yes/no) [default=no]: yes
IP address or FQDN of an existing cluster node: 192.168.0.201
Cluster fingerprint: 98a0d46bdeb9e97cd265d1095dbaabc9d02384056c75c100a1614ed5ade8a705
You can validate this fingerprint by running "lxc info" locally on an existing node.
Is this the correct fingerprint? (yes/no) [default=no]: yes
Cluster trust password:
All existing data is lost when joining a cluster, continue? (yes/no) [default=no] yes
Choose "source" property for storage pool "local": /dev/sdb
Choose "zfs.pool_name" property for storage pool "local": local
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
config: {}
networks: []
storage_pools: []
profiles: []
cluster:
  server_name: ubulxd3
  enabled: true
  member_config:
  - entity: storage-pool
    name: local
    key: source
    value: /dev/sdb
    description: '"source" property for storage pool "local"'
  - entity: storage-pool
    name: local
    key: zfs.pool_name
    value: local
    description: '"zfs.pool_name" property for storage pool "local"'
  cluster_address: 192.168.0.201:8443
  cluster_certificate: |
    -----BEGIN CERTIFICATE-----
    MIIB+jCCAYCgAwIBAgIQefXGwywovTGIUgeaImmNOzAKBggqhkjOPQQDAzA1MRww
    GgYDVQQKExNsaW51eGNvbnRhaW5lcnMub3JnMRUwEwYDVQQDDAxyb290QHVidWx4
    ZDEwHhcNMTkwODI3MDA0NTUwWhcNMjkwODI0MDA0NTUwWjA1MRwwGgYDVQQKExNs
    aW51eGNvbnRhaW5lcnMub3JnMRUwEwYDVQQDDAxyb290QHVidWx4ZDEwdjAQBgcq
    hkjOPQIBBgUrgQQAIgNiAARYinCNFMZIkOs12EvI2rqJxk0G14kK91dSdsc+Gwb0
    ysfPVWfBjNIV+yi0GR3O7snjfQULZh7Jxglrk9LqeJKmsLNh5K0fLTZca/WWtMee
    cMIHRQZWqF49/5EPmCKwNSujVTBTMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAK
    BggrBgEFBQcDATAMBgNVHRMBAf8EAjAAMB4GA1UdEQQXMBWCB3VidWx4ZDGHBMCo
    AMmHBMCoAOcwCgYIKoZIzj0EAwMDaAAwZQIwEE2NGYjzV39v0xZyXqCcqvPDEsLK
    VPiIOwjxzIXm9xnEuR9eWFRGt3h4HBWyI7TWAjEAm7Yo2roaippPvK1CjmSdkmXZ
    qE71OsyhGWvC6fRvm7bs3h3vt782yiwHjm0BOmVu
    -----END CERTIFICATE-----
  server_address: 192.168.0.203:8443
  cluster_password: C7uster
