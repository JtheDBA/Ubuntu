# LXD

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

>LXC is the well known set of tools, templates, library and language bindings. It's pretty low level, very flexible and covers just about every containment feature supported by the upstream kernel.
>LXD is the new LXC experience. It offers a completely fresh and intuitive user experience with a single command line tool to manage your containers. Containers can be managed over the network in a transparent way through a REST API. It also works with large scale deployments by integrating with cloud platforms like OpenNebula and OpenStack.

My experience with LXD can be summed up as an aging nerd screwing around while drinking beer. I have no professional experience with LXD but I believe it does have a place in the landscape of ? as a Service, clouds, containers, inserts buzzwords here.
Here is my current drinking project/[Virtual Box LXD Lab](../virtualbox/LXD Lab.md)

## Top Official Resources?

-  [Linux Containers](https://linuxcontainers.org/)
-  [Linux Containers - Image server](https://us.images.linuxcontainers.org/)
-  [LXD - system container manager](https://lxd.readthedocs.io/en/latest/)

## Installation

**For 18.04 LTS and beyond, the `snap` is recommended over the `apt` version? Is this correct experts?**

```Bash
sudo apt purge -y lxd lxd-client
sudo snap install lxd
```

If using BTRFS everything as of 18.04 LTS is ready. If using ZFS as a filesystem you will need to install the parts and restart: `sudo apt install -y zfsutils-linux; sudo shutdown -r 1; exit`

## Resources

[reddit](https://www.reddit.com/r/LXD/)

-  [LXD Networking How To](https://www.reddit.com/r/LXD/comments/7zixx5/lxd_networking_how_tos/)

[GitHub](https://github.com/)

-  [LXD Tips](https://github.com/bmullan/Collection-of-LXD-Usage-Tips) - Brian Mullins's collection of LXD tips/hints found online over time
-  [ciab-remote-desktop](https://github.com/bmullan/ciab-remote-desktop) - Brian Mullins's Cloud in a Box (CIAB) Remote Desktop System
-  [mini-stack](https://github.com/containercraft/mini-stack) - Kathryn Morgan's Hypervisor Lab & Development Stack
-  [ContainerBox](https://github.com/AlexandreDey/ContainerBox/) - GitHub - AlexandreDey/ContainerBox: Tool on top of LXD to easily create and use graphical containers
-  [trentdocs_website](https://github.com/TrentSPalmer/trentdocs_website)

[Documentation and Blogs](https://lxd.readthedocs.io/en/latest/)
-  [Trent Docs](https://docs.trentsonlinedocs.xyz)
   -  [LXD Container Home Server Networking For Dummies](https://docs.trentsonlinedocs.xyz/lxd_container_home_server_networking_for_dummies/)
   -  [More Notes and Tips for Using LXD](https://docs.trentsonlinedocs.xyz/lxd_container_foo/)
-  [Galileo Labs LXD Tips](http://wiki.csgalileo.org/tips:lxd)
-  LinkedIn - Ahnaf Shahriar
   -  [LXC Networking Part 1 - Introduction](https://www.linkedin.com/pulse/lxc-networkingintroduction-part-1-ahnaf-shahriar/)
   -  [LXC Networking Part 2 - Routing 101](https://www.linkedin.com/pulse/lxc-networkingrouting-101-ahnaf-shahriar/)
   -  [LXC Networking Part 3 - Using LXC/LXD](https://www.linkedin.com/pulse/lxc-networkingusing-lxclxdpart-3-ahnaf-shahriar/)
-  [Ubuntu 18.04 LXD/LXC, ZFS, Docker, and Advanced Networking](https://homelab.city/ubuntu-18-04-lxd-zfs-docker-and-networking/) - maybe outdated but running Docker and LXD and Docker in a container LXD
-  [How to easily run graphics-accelerated GUI apps in LXD containers on your Ubuntu desktop](https://blog.simos.info/how-to-easily-run-graphics-accelerated-gui-apps-in-lxd-containers-on-your-ubuntu-desktop/) – Mi blog lah!
-  [Creating an LXD container for graphics applications](https://bitsandslices.wordpress.com/2015/12/08/creating-an-lxd-container-for-graphics-applications/) - bitsandslices
-  [Clustering in LXD 3.0](https://www.mightygio.com/blog/clustering-in-lxd-3/)
-  [LXD Clusters: A Primer](https://ubuntu.com/blog/lxd-clusters-a-primer)
-  [Stéphane Graber's website](https://stgraber.org/category/lxd/)
