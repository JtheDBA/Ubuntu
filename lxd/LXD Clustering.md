# LXD Clustering

Status

-  [X] Ubuntu 20.04 Server
-  [ ] Ubuntu 20.04 Mini
-  [ ] Hardening
-  [ ] Ansible


-  [Clustering](https://github.com/lxc/lxd/blob/master/doc/clustering.md)


## Important Notes and Quotes

> It is strongly recommended that the number of nodes in the cluster be at least three, so the cluster can survive the loss of at least one node and still be able to establish quorum for its distributed state (which is kept in a SQLite database replicated using the Raft algorithm). If the number of nodes is less than three, then only one node in the cluster will store the SQLite database. When the third node joins the cluster, both the second and third nodes will receive a replica of the database.

## Nodes

-  `lxd01-ubu2004` - `192.168.0.91` - storage: 120GB BTRFS on `/dev/sdc` network: `172.16.91.1`
-  `lxd02-ubu2004` - `192.168.0.92` - storage: 120GB BTRFS on `/dev/sdc` network: `172.16.91.1`
-  `lxd03-ubu2004` - `192.168.0.93` - storage: 120GB BTRFS on `/dev/sdc` network: `172.16.91.1`

## LXD installation

The first thing I do is start a root shell and stay in it for the duration of the document.

LXD is installed with Ubuntu Server as a snap with a specific version; 4.05 as of this document. Use `snap` to list the current versions of installed snaps and search for newer versions of LXD. To install a newer version either `refresh lxd` to the latest or the most recent version from the stable channel.

``` Bash
sudo -i

snap list
snap search lxd

snap refresh lxd --channel=4.11/stable
or 
snap refresh lxd --channel=latest/stable
```

## Forming a cluster

### Bootstrap LXD node

> First you need to choose a bootstrap LXD node. It can be an existing LXD server or a brand new one. Then you need to initialize the bootstrap node and join further nodes to the cluster. This can be done interactively or with a preseed file.
>
> Note that all further nodes joining the cluster must have identical configuration to the bootstrap node, in terms of storage pools and networks. The only configuration that can be node-specific are the source and size keys for storage pools and the `bridge.external_interfaces` key for networks.
>

`cat lxd.preseed | lxd init --preseed`

I chose the preseed method. Create the `lxd.preseed`file, initialize LXD and show the info for the newly initialized system to get the certificate to use for other `lxd.preseed` files.


``` Bash
vi lxd.preseed

cat lxd.preseed | lxd init --preseed

lxc info
```

`lxd.preseed` file:

``` YAML
config:
  core.trust_password: puTy0ur5up3rsekretpaZswordhere
  core.https_address: 192.168.0.91:8443
  images.auto_update_interval: 15
storage_pools:
- name: default
  driver: btrfs
  config:
    source: /dev/sdc
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: 172.16.91.1/24
    ipv6.address: none
profiles:
- name: default
  devices:
    root:
      path: /
      pool: default
      type: disk
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
cluster:
  server_name: lxd01-ubu2004
  enabled: true
```

The `lxc info` output contains the certificate...

### Additional LXD nodes

Note, I was unable to get the `lxd.preseed` file to work for the additional LXD nodes so I chose the manual method then chose to print the YAML file at the end. The contents below are the output. I could not find this information anywhere searching online so I hope it is useful here.

`lxd.preseed` file

``` YAML
config: {}
networks: []
storage_pools: []
profiles: []
cluster:
  server_name: SN
  enabled: true
  member_config:
  - entity: storage-pool
    name: default
    key: size
    value: ""
    description: '"size" property for storage pool "default"'
  - entity: storage-pool
    name: default
    key: source
    value: /dev/sdc
    description: '"source" property for storage pool "default"'
  cluster_address: 192.168.0.91:8443
  cluster_certificate: |
    -----BEGIN CERTIFICATE-----
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    aaaaaaaaaaaaaaa=
    -----END CERTIFICATE-----
  server_address: IP:8443
  cluster_password: puTy0ur5up3rsekretpaZswordhere
```

Assuming you already have the host name and the IP address configured you can use the following to perform the LXD initialization:

``` Bash
SN=`hostname`
IP=`ifconfig | sed -e '/inet 192/!d;s/^.*inet.\(192.168.0.[0-9]*\).*$/\1/'`
sed -i -e "s/server_name: SN/server_name: ${SN}/;s/server_address: IP/server_address: ${IP}/" lxd.preseed
cat lxd.preseed | lxd init --preseed
```


## Upgrading

blocking

snap refresh lxd --channel=latest/stable

# References

-  [Inexpensive highly available LXD cluster: Server setup](https://stgraber.org/2020/12/18/inexpensive-highly-available-lxd-cluster-server-setup/)
