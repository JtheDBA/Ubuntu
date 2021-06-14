Skip to main content
Primary links
Home Ansible Docker Kubernetes Linux LXD OpenStack Virtualization HowTo
LXD
virtualizationlxd
Install LXD as snap package

sudo apt install -y snapd
sudo snap install lxd
 
# configure default storage
lxc storage create zfs zfs source=rpool/lxd
lxc profile device add default root disk path=/ pool=zfs
 
# configure default network
lxc network create lxdbr0
lxc profile device add default eth0 nic nictype=bridged parent=lxdbr0
 
lxc profile create default
lxd init 
--auto
Install

apt install lxd lxd-client
# https://raw.githubusercontent.com/panticz/installit/master/install.lxd.sh

# Add user to group

sudo usermod -a -G lxd ${USER}

Create VM

# Container
lxc launch images:ubuntu/20.04 u2004
lxc launch images:ubuntu/20.04/cloud u2004c
lxc launch ubuntu:20.04 u2004
lxc launch ubuntu:trusty trusty
 
# VMs
lxc launch images:ubuntu/21.04 vm2104 --vm
lxc launch images:ubuntu/21.04/cloud vm2104c --vm
 
lxc launch images:centos/7 centos7
lxc exec xenial bash
 
# remove container
lxc delete xenial -f
 
# list container name only
lxc list -c n --format csv
 
# -c volatile.dev-mgmt.hwaddr=00:11:22:33:44:55
Create priviliged VM

CONTAINER_NAME=vm1
CONTAINER_IP=10.0.1.23
lxc launch ubuntu:18.04 ${CONTAINER_NAME} -p mgmt-dev -c security.privileged true
lxc config set ${CONTAINER_NAME} boot.autostart true
lxc config set ${CONTAINER_NAME} security.privileged true
lxc config device add ${CONTAINER_NAME} eth1 nic mtu=9000 nictype=macvlan parent=vlan-1234
Nested
https://ubuntu.com/blog/nested-containers-in-lxd

lxc config set ltsp security.nesting true
lxc config set ltsp security.privileged true
Console

Ctrl-a q
CLI

lxc list
Image

# list local images
lxc image list
 
# list all remote images
lxc image list images:
 
# search specific remote image
lxc image list images: 20.04
lxc image list images: ubuntu
lxc image list images: centos
 
lxc remote add --protocol simplestreams ubuntu-minimal https://cloud-images.ubuntu.com/minimal/releases/
 
lxc remote add --protocol simplestreams ubuntu-minimal-daily https://cloud-images.ubuntu.com/minimal/daily/
lxc launch ubuntu-minimal-daily:eoan
 
lxc remote add --protocol simplestreams ubuntu-minimal https://cloud-images.ubuntu.com/minimal/releases/
lxc launch ubuntu-minimal:disco
 
# image info
lxc image info images:ubuntu/20.04/cloud
 
# refresh
lxc image refresh <IMAGE_HASH>
Get started
https://linuxcontainers.org/lxd/getting-started-cli/

Rootfs

/var/lib/lxd/containers/<CONTAINER>/rootfs
Ansible module
http://docs.ansible.com/ansible/latest/lxd_container_module.html

Configuration

# Non-interactive configuration via preseed YAML
https://lxd.readthedocs.io/en/latest/preseed/
 
/etc/default/lxd-bridge
/var/lib/lxd/containers/<CONTAINER>/rootfs/config
 
~/.config/lxc/config.yml
...
aliases:
  list: list -c n,user.fqdn:FQDN,s46tS
 
# output only container name
lxc list -c n --format csv
Containers
https://uk.images.linuxcontainers.org/

Network
https://lxd.readthedocs.io/en/latest/networks/
https://ubuntu.com/blog/network-management-with-lxd-2-3

lxc config device add container1 eth1 nic name=eth1 nictype=bridged parent=br0
lxc config device remove router eth1
lxc config device add router eth1 nic nictype=physical parent=eth0
lxc network set lxdbr0 ipv4.routes 100.200.200.48/29
 
# Fixed IP ?
echo "dhcp-host=xenial,10.135.253.200" >> /etc/lxd/dnsmasq.conf
sed -i 's|LXD_CONFILE=""|LXD_CONFILE="/etc/lxd/dnsmasq.conf"|' /etc/default/lxd-bridge
 
lxc network show lxdbr0
 
# cat /etc/dnsmasq.d/lxd
server=/lxd/10.135.253.1
bind-interfaces
except-interface=lxdbr0
 
# static
lxc stop c1
lxc network attach lxdbr0 c1 eth0 eth0
lxc config device set c1 eth0 ipv4.address 10.99.10.42
lxc start c1
Snapshot

# create snapshot
lxc snapshot u1804 ssh
 
# list (also snapshots)
lxc info u1804
 
# restore snapshot
lxc restore u1804 ssh
 
# delete snapshot
lxc delete u1804/list
Snap

snap install lxd && lxd.migrate
 
apt install -t <release>-backports lxd lxd-client
Configure bridge

lxc profile device remove default eth0
lxc profile device add default eth0 nic nictype=macvlan parent=br0 name=eth0
lxc profile show default
 
# test me
lxc network set lxdbr0 ipv4.routes PUBLIC-IP/32
create profile

lxc profile copy default mgmt-dev
# lxc profile list
lxc profile device set mgmt-dev eth0 nictype macvlan
lxc profile device set mgmt-dev eth0 parent mgmt-dev-v1234
lxc profile show mgmt-dev
 
# change profile
lxc profile assign container1 mgmt-prod
 
# add / delete profile
lxc profile add container1 profile1
lxc profile remove container1 profile1
Add / remove interface to container

lxc config device add bifrost-dev eth1 nic name=eth1 nictype=macvlan parent=ipmi-dev-v4421
lxc config device del bifrost-dev2 eth1
Configure MAC address

lxc config set CONAINER_1 volatile.eth0.hwaddr 00:11:22:33:44:55
lxc launch ubuntu:x --config volatile.eth0.hwaddr=00:11:22:33:44:55
Pass through external USB interface as eth1

lxc stop router
lxc config device remove router eth1
lxc start router
lxc config device add router eth1 nic nictype=physical parent=enx0022f731b929
Mount drive

lxc config device add bionic1 images disk source=/var/lib/images path=/media/images
Configure http(s) proxy

# Configure http proxy for LXD daemon
lxc config set core.proxy_http http://proxy.example.com:8080
lxc config set core.proxy_https http://proxy.example.com:8080
lxc config set core.proxy_ignore_hosts db.example.com
sudo service lxd restart
 
# Configure http proxy inside of container
echo "export http_proxy=http://proxy.example.com:8080" | lxc shell <container_name> -- tee -a /etc/environment
echo "export https_proxy=http://proxy.example.com:8080" | lxc shell <container_name> -- tee -a /etc/environmen
# test me (set limits)
lxc config set container1 limits.kernel.nofile 90000
lxc restart container1

Deploy SSH key

#cat ~/.ssh/id_rsa.pub | lxc shell container1 -- tee -a /root/.ssh/authorized_keys
lxc file push --uid 0 --gid 0 --mode 600 ~/.ssh/id_rsa.pub ${CONTAINER}/root/.ssh/authorized_keys
Documentation
https://github.com/lxc/lxd/blob/master/doc/containers.md

Issues

# ERROR    utils - utils.c:lxc_setup_keyring:1801 - Disk quota exceeded - Failed to create kernel keyring
lxc profile set default security.syscalls.blacklist "keyctl errno 38"
Export / backup container

# https://discuss.linuxcontainers.org/t/backup-the-container-and-install-it-on-another-server/463/2
CONTAINER=my-container-1
lxc publish ${CONTAINER} --alias ${CONTAINER}
lxc image export ${CONTAINER} ${CONTAINER}
lxc image delete ${CONTAINER}
 
# lxc delete ${CONTAINER}
Search for eth1 in all containers

for CONTAINER in $(lxc list -c n --format csv); do
    echo ${CONTAINER}
    lxc config show ${CONTAINER} | grep "volatile.eth0.name: eth1"
done
 
# timezone
lxc config set contrainer1 environment.TZ Europe/Berlin
Init

# lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: 
Do you want to configure a new storage pool? (yes/no) [default=yes]: 
Name of the new storage pool [default=default]: 
Name of the storage backend to use (dir, lvm, zfs) [default=zfs]: 
Create a new ZFS pool? (yes/no) [default=yes]: 
Would you like to use an existing block device? (yes/no) [default=no]: 
Size in GB of the new loop device (1GB minimum) [default=45GB]: 
Would you like to connect to a MAAS server? (yes/no) [default=no]: 
Would you like to create a new local network bridge? (yes/no) [default=yes]: 
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
Would you like LXD to be available over the network? (yes/no) [default=no]: 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes] 
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
config: {}
cluster: null
networks:
- config:
    ipv4.address: auto
    ipv6.address: none
  description: ""
  managed: false
  name: lxdbr0
  type: ""
storage_pools:
- config:
    size: 45GB
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
change priviliged to unpriviliged container

lxc config set c1 security.privileged false
chown 100000.100000 /additional/mount/path/on/hypervisor -R
Update APT packages in all container

# --download-only
for CONTAINER in $(lxc list -c n --format csv); do
    echo ${CONTAINER}
    lxc exec ${CONTAINER} -- bash -c "apt update -qq && apt dist-upgrade -y" | tee ${CONTAINER}.dist-upgrade.$(date -I).log
done
distrobuilder
https://github.com/lxc/distrobuilder

tcpdump (todo)

# on the hypervisor
ln -s /etc/apparmor.d/usr.sbin.tcpdump /etc/apparmor.d/disable/
service apparmor reload
Device documentation
https://github.com/lxc/lxd/blob/master/doc/containers.md

Docker and LXD on same host

# cat /etc/docker/daemon.json
{
    "iptables": false
}
cloud-init
https://blog.simos.info/how-to-preconfigure-lxd-containers-with-cloud-init/

 
DB edit

lxd sql global "DELETE FROM containers_devices WHERE name='root' AND type='disk';"
LXD monitor

lxc monitor --pretty --type logging
USB
https://stgraber.org/2017/03/27/usb-hotplug-with-lxd-containers/

Find container using devices

for CONTAINER in $(lxc list -c n --format csv); do
    echo ${CONTAINER}
    #lxc config show ${CONTAINER} | grep pool
    lxc config show ${CONTAINER} | grep devices -5
done
Update all containers

for CONTAINER in $(lxc list -c n --format csv); do
    echo ${CONTAINER}
    lxc exec ${CONTAINER} -- apt update
    lxc exec ${CONTAINER} -- apt dist-upgrade -y
    lxc exec ${CONTAINER} -- apt clean
    lxc exec ${CONTAINER} -- apt autoremove -y
    echo
done
journalctl -u snap.lxd.daemon
Mounting Devices in LXD
https://ericroc.how/mounting-devices-in-lxd.html#mounting-devices-in-lxd

# share directory
lxc config device add container1 modules disk source=/usr/lib/modules path=/usr/lib/modules
LXD cloud-config profile

- name: Create cloud-config profile
  lxd_profile:
    name: cloud-config
    config:
      user.user-data: |
        #cloud-config
        locale: en_US.UTF-8
        timezone: Europe/Berlin
        # apt:
        #   disable_suites: [release, updates, backports, security]
        #   primary:
        #     - arches: [amd64]
        #       uri: http://mirror.example.com/current/ubuntu
        apt:        
          sources_list: |
            deb [arch=amd64] http://mirror.example.com/current/ubuntu $RELEASE main restricted universe multiverse
            deb [arch=amd64] http://mirror.example.com/current/ubuntu $RELEASE-updates main restricted universe multiverse
            deb [arch=amd64] http://mirror.example.com/current/ubuntu $RELEASE-security main restricted universe multiverse
            deb [arch=amd64] http://mirror.example.com/current/ubuntu $RELEASE-backports main restricted universe multiverse
        apt_upgrade: true
        package_upgrade: true
        packages:
          - openssh-server
        disable_root: false
        ssh_authorized_keys:
          - "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"          
      user.network-config: |
        version: 1
        config:
          - type: physical
            name: mgmt
            subnets:
              - type: dhcp
Expose port

lxc config device add gitea port8080 proxy listen=tcp:0.0.0.0:8080 connect=tcp:127.0.0.1:3000
Links
https://insights.ubuntu.com/2016/03/22/lxd-2-0-your-first-lxd-container/
https://www.cyberciti.biz/faq/how-to-install-lxd-container-hypervisor-on-ubuntu-16-04-lts-server/
https://lxd.readthedocs.io/en/latest/
https://linuxcontainers.org/lxd/getting-started-cli/
https://help.ubuntu.com/lts/serverguide/lxd.html
https://cloud-images.ubuntu.com/releases/
https://stgraber.org/2016/03/30/lxd-2-0-image-management-512/
https://insights.ubuntu.com/2017/02/14/network-management-with-lxd-2-3/
https://help.ubuntu.com/lts/serverguide/lxd.html.en
