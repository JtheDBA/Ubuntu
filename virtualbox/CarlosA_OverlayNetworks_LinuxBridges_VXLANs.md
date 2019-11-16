# How to create overlay networks using Linux Bridges and VXLANs

[How to create overlay networks using Linux Bridges and VXLANs](https://ilearnedhowto.wordpress.com/2017/02/16/how-to-create-overlay-networks-using-linux-bridges-and-vxlans/)

Scenario
I have a single LAN, and I want to have several overlay networks with multiple VMs in each of them. I want that one set of VMs can communicate between them, but I don’t want that other set of VMs even know about the first set: I want to isolate networks from multiple tenants.

The next figure shows what I wan to do:

overlay-1

The left hand part of the image shows that will happen, and the right hand side of the image shows what the users in the hosts will have the vision that happen. The hosts which end in “1” will see that they are they are alone in their LAN, and the hosts which end in “2” will see that they are alone in their LAN.

Set up
We will create a “poor man setup” in which we will have two VMs that are simulating the hosts, and we will use LXC containers that will act as “guests”.

The next figure shows what we are creating

overlay-2

node01 and node02 are the hosts that will host the containers. Each of them have a physical interface named ens3, with IPs 10.0.0.28 and 10.0.0.31. We will create on each of them a bridge named br-vxlan-<ID> to which we should be able to bridge our containers. And these containers will have a interface (eth0) with an IP addresses in the range of 192.168.1.1/24.

To isolate the networks, we are using VXLANS with different VXLAN Network Identifier (VNI). In our case, 10 and 20.

Starting point
We have 2 hosts that can ping one to each other (node01 and node02).

root@node01:~# ping -c 2 node02
PING node02 (10.0.0.31) 56(84) bytes of data.
64 bytes from node02 (10.0.0.31): icmp_seq=1 ttl=64 time=1.17 ms
64 bytes from node02 (10.0.0.31): icmp_seq=2 ttl=64 time=0.806 ms
and

root@node02:~# ping -c 2 node01
PING node01 (10.0.0.28) 56(84) bytes of data.
64 bytes from node01 (10.0.0.28): icmp_seq=1 ttl=64 time=0.740 ms
64 bytes from node01 (10.0.0.28): icmp_seq=2 ttl=64 time=0.774 ms
In each of them I will make sure that I have installed the package iproute2 (i.e. the command “ip”).

In order to verify that everything is properly working, in each node, we will install the latest version of lxd according to this (in my case, I have lxd version 2.8). The one shipped with ubuntu 16.04.1 is 2.0 and will not be useful for us because we want that it is able to manage networks.

Anyway, I will offer an alternative for non-ubuntu users that will consist in creating a extra interface that will be bridged to the br-vxlan interface.

Let’s begin
The implementation of vxlan for the linux bridges works encapsulating traffic in multicast UDP messages that are distributed using IGMP.

In order to enable that the TCP/IP traffic is encapsulated through these interfaces, we will create a bridge and will attach the vxlan interface to that bridge. At the end, a bridge works like a network hub and forwards the traffic to the ports that are connected to it. So the traffic that appears in the bridge will be encapsulated into the UDP multicast messages.

For the creation of the first VXLAN (with VNI 10) we will need to issue the next commands (in each of the nodes)

ip link add vxlan10 type vxlan id 10 group 239.1.1.1 dstport 0 dev ens3
ip link add br-vxlan10 type bridge
ip link set vxlan10 master br-vxlan10
ip link set vxlan10 up
ip link set br-vxlan10 up
In these lines…

First we create a vxlan port with VNI 10 that will use the device ens3 to multicast the UDP traffic using group 239.1.1.1 (using dstport 0 makes use of the default port).
Then we will create a bridge named br-vxlan10 to which we will bridge the previously created vxlan port.
Finally we will set both ports up.
Now that we have the first VXLAN, we will proceed with the second:

ip link add vxlan20 type vxlan id 20 group 239.1.1.1 dstport 0 dev ens3
ip link add br-vxlan20 type bridge
ip link set vxlan20 master br-vxlan20
ip link set vxlan20 up
ip link set br-vxlan20 up
Both VXLANs will be created in both nodes node01 and node02.

Tests and verification
At this point, we have the VXLANs ready to be used, and the traffic of each port that we bridge to the br-vxlan10 or br-vxlan20 will be multicasted using UDP to the network. As we have several nodes in the LAN, we will have VXLANs that span across multiple nodes.

In practise, the bridges br-vxlan10 of each node will be in LAN (each port included in such bridge of each node will be in the same LAN). The same occurs for br-vxlan20.

And the traffic of br-vxlan10 will not be visible in br-vxlan20 and vice-versa.

Verify using LXD containers
This is the test that will be more simple to understand as it is conceptually what we want. The only difference is that we will create containers instead of VMs.

In order to verify that it works, we will create the containers lhs1 (in node01) and and rhs1 (in node02) that will be attached to the br-vxlan10. In node01 we will execute the following commands:

lxc profile create vxlan10
lxc network attach-profile br-vxlan10 vxlan10
lxc launch images:alpine/3.4 lhs1 -p vxlan10
sleep 10 # to wait for the container to be up and ready
lxc exec lhs1 ip addr add 192.168.1.1/24 dev eth0
What we are doing is the next:

Creating a LXC profile, to ensure that it has not any network interface.
Making that the profile uses the bridge that we created for the VXLAN.
Creating a container that uses the profile (and so, will be attached to the VXLAN).
Assigning the IP address 192.168.1.1 to the container.
In node02, we will create other container (rhs1) with IP 192.168.1.2:

lxc profile create vxlan10
lxc network attach-profile br-vxlan10 vxlan10
lxc launch images:alpine/3.4 rhs1 -p vxlan10
sleep 10 # to wait for the container to be up and ready
lxc exec rhs1 ip addr add 192.168.1.2/24 dev eth0
And now, we have one container in each node that feels like if it was in a LAN with the other container.

In order to verify it, we will use a simple server that echoes the information sent. So in node01, in lhs1 we will start netcat listening in port 9999:

root@node01:~# lxc exec lhs1 -- nc -l -p 9999
And in node02, in rhs1 we will start netcat connected to the lhs1 IP and port (192.168.1.1:9999):

root@node02:~# lxc exec rhs1 -- nc 192.168.1.1 9999
Anything that we write in this node will get output in the other one, as shown in the image:

lxc-over

Now we can create the other containers and see what happens.

In node01 we will create the container lhs2 connected to vxlan20 and the same IP address than lhs1 (i.e. 192.168.1.1):

lxc profile create vxlan20
lxc network attach-profile br-vxlan20 vxlan20
lxc launch images:alpine/3.4 lhs2 -p vxlan20
sleep 10 # to wait for the container to be up and ready
lxc exec lhs2 ip addr add 192.168.1.1/24 dev eth0
At this point, if we try to ping to IP address 192.168.1.2 (which is assigned to rhs1), it should not work, as it is in the other VXLAN:

root@node01:~# lxc exec lhs2 -- ping -c 2 192.168.1.2
PING 192.168.1.2 (192.168.1.2): 56 data bytes

--- 192.168.1.2 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
Finally, in node02, we will create the container rhs2, attached to vxlan20, and the IP address 192.168.1.2:

lxc profile create vxlan20
lxc network attach-profile br-vxlan20 vxlan20
lxc launch images:alpine/3.4 rhs2 -p vxlan20
sleep 10 # to wait for the container to be up and ready
lxc exec rhs2 -- ip addr add 192.168.1.2/24 dev eth0
And now we can verify that each pair of nodes can communicate between them and the other traffic will not arrive. The next figure shows that it works!test02

Now you could have fun capturing the traffic in the hosts and get things like this:

traffic.png

You ping a host in vxlan20 and if you dump the traffic from ens3 you will get the top left traffic (the traffic in “instance 20”, i.e. VNI 20), but there is no traffic in br-vxlan10.

I suggest to have fun with wireshark to look in depth at what is happening (watch the UDP traffic, how it is translated using the VXLAN protocol, etc.).

Verify using other devices
If you cannot manage to use VMs or LXD containers, you can create a veth device and assign the IP addresses to it. Then ping through that interface to generate traffic.

ip link add eth10 type veth peer name eth10p
ip link set eth10p master br-vxlan10
ip link set eth10 up
ip link set eth10p up
And we will create other interface too

ip link add eth20 type veth peer name eth20p
ip link set eth20p master br-vxlan20
ip link set eth20 up
ip link set eth20p up
Now we will set the IP 192.168.1.1 to eth10 and 192.168.1.2 to eth20, and will try to ping from one to the other:

# ip addr add 192.168.1.1/24 dev eth10
# ip addr add 192.168.2.1/24 dev eth20
# ping 192.168.2.1 -c 2 -I eth10
PING 192.168.2.1 (192.168.2.1) from 192.168.1.1 eth10: 56(84) bytes of data.
From 192.168.1.1 icmp_seq=1 Destination Host Unreachable
From 192.168.1.1 icmp_seq=2 Destination Host Unreachable

--- 192.168.2.1 ping statistics ---
2 packets transmitted, 0 received, +2 errors, 100% packet loss, time 1000ms
pipe 2
Here we see that it does not work.

I had to set IP addresses in different ranges. Otherwise the interfaces do not work properly.

Now, in node02, we will create the interfaces and set IP addresses to them (192.168.1.2 to eth10 and 192.168.2.2 to eth20).

ip link add eth10 type veth peer name eth10p
ip link set eth10p master br-vxlan10
ip link set eth10 up
ip link set eth10p up
ip link add eth20 type veth peer name eth20p
ip link set eth20p master br-vxlan20
ip link set eth20 up
ip link set eth20p up
ip addr add 192.168.1.2/24 dev eth10
ip addr add 192.168.2.2/24 dev eth20
And now we can try to ping to the interfaces in the corresponding VXLAN.

root@node01:~# ping 192.168.1.2 -c 2 -I eth10
PING 192.168.1.2 (192.168.1.2) from 192.168.1.1 eth10: 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=64 time=10.1 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=64 time=4.53 ms

--- 192.168.1.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 4.539/7.364/10.189/2.825 ms
root@node01:~# ping 192.168.2.2 -c 2 -I eth10
PING 192.168.2.2 (192.168.2.2) from 192.168.1.1 eth10: 56(84) bytes of data.

--- 192.168.2.2 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1007ms
If we inspect what is happening using tcpdump, we’ll see that the traffic arrives to one interface and not to the other, as it is shown in the next figure:

dump.png

What we got here…
At the end, we have achived to a situation in which we have multiple isolated LANs over a single LAN. The traffic in one LAN is not seen in the other LANs.

This enables to create multi-tenant networks for Cloud datacenters.

Troubleshooting
During the tests I created a bridge in which the traffic was not forwarded from one port to the others. I tried to debug what was happening, whether it was affected by ebtables, iptables, etc. and at first I found no reason.

I was able to solve it by following the advice in this post. In fact, I did not trusted on it and rebooted, and while some of the settings were set to 1, it worked from then on.

$ cd /proc/sys/net/bridge
$ ls
 bridge-nf-call-arptables bridge-nf-call-iptables
 bridge-nf-call-ip6tables bridge-nf-filter-vlan-tagged
$ for f in bridge-nf-*; do echo 0 > $f; done
The machine in which I was doing the tests is not usually powered off, so maybe it was on for at least 2 months. Maybe some previous tests drove me to that problem.

I have faced this problem again and I was not comfortable with a solution “based on the faith”. So I searched a bit more and I found this post. Now I know what these files in /proc/sys/net/bridge mean and now I know that the problem was about iptables. The problem is that the files bridge-nf-call-iptables, etc. mean if the rules should go through iptables/arptables… before forwarding them to the ports in the bridge. So if you set a zero to these files, you will not have any iptables related problem.

If you find that the traffic is not forwarded to the ports, you should double-check the iptables and so on. In my case the “problem” was that forwarding was prevented by default. A “easy to check” solution is to check the filter table of iptables:

`iptables -t filter -S`
-P INPUT ACCEPT
-P FORWARD DROP
-P OUTPUT ACCEPT
...
In my case, the filter dropped the traffic. If I want the traffic to be forwarded, I must explicitly accept it by adding a rule such as

`iptables -t FILTER -A FORWARD -i br-vxlan20 -j ACCEPT`

# Resources from Article

- [How to create a overlay network using Open vSwitch in order to connect LXC containers](https://ilearnedhowto.wordpress.com/2016/09/16/how-to-create-a-overlay-network-using-open-vswitch-in-order-to-connect-lxc-containers/)
- [Linux bridge: Self-service networks](https://docs.openstack.org/newton/networking-guide/deploy-lb-selfservice.html)
- [VXLAN Series – Different Components – Part 1](https://blogs.vmware.com/vsphere/2013/04/vxlan-series-different-components-part-1.html)

