# My Ubuntu Crap

Hi there.

If you found this by accident: this is a complete (incomplete?) work in progress from some aging nerd with aging technology (that is still good for some things) in his basement attempting to stay current with some things while providing services for one additional human being and three cats in our meager four level dwelling in the Midwest United States. I'm also 1) curious what you were searching for or how you found this and 2) welcome, hope you find something useful.

If you were given this repository by me, hi there. Hopefully you find something here that is usable and might save you time and frustration. Feel free to contribute, laugh at me, buy me a beer or six or just nerd up with me.

In both cases, I'm in the process of moving years of text files containing scripts, instructions, scribbles, various notes, frustrations, successes and other goodies from Dropbox to GitHub (probably to move somewhere else soon).

Note, I am aware that referring to knowledge, information, questions and useful stuff as "crap" is probably not the most polite term but is by far the easiest to dictate into Dragon software so - now you know. It also makes my `git` scripts pure comedy...

Also note, I am well aware of solutions like Vagrant and Docker.

## Recent Updates

#### June 8, 2021



#### March 30, 2021

I have returned to this project after taking a couple months off to clear my head and learn some other crap.

During that time I completely abandoned the use of VirtualBox and replaced it with a combination of Hyper-V and Windows Subsystem for Linux as my primary virtualization layer and learned more about LXD and Docker. My opinion: VirtualBox is being pushed aside by advancements in technologies in the Windows and Linux world and simply is more of a chore to maintain and fewer guests are functioning out-of-the-box within it.

I'm going to thin down this repository to start a common point then begin to branch out depending upon the target audience. So if you're building a single home server or like me learning the basics of technologies in this new world hopefully there's something here for you.

## Standard Disclaimers

*Do not assume I know what I am doing or anything should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*

*This is always work in progress. Learn first, copy and paste second. If I feel anything is "final" I will note it.*

## What is Here

There is crap for home users and crap for professional uses i.e. small businesses, etc. I am likely not qualified to comment on large Enterprise crap as a basement hobbyist; but I may try or pretend to be.

If you are a home user I would probably recommend you simply skip what is here and learn how to set up a basic Ubuntu Server and run Docker containers. There are plenty of resources on the Internet with `docker-compose` solutions for entire home servers or a simple Plex server.

If you are still learning, like I am, or perhaps inherited some servers at work then probably check out the common crap - which explains how to set up a local package cache, a place for basic installation and operational scripts, how to harden your server, what you can do with Docker and how you can use Ansible for orchestration. 

### Directories

- `common` contains various work in progress markdown documents for applications, containers, etc. like a centralized apt package cache [apt-cacher-ng](common/apt-cacher-ng.md) - download packages once instead of for each existing or new installation
- `home` contains the `/home/sadmin` directory for the `sadmin` system administrator user and a good starting point for, hopefully, most everything including scripts, playbooks, etc.
- `lxd` contains my experiments with [LXD system container manager](https://linuxcontainers.org/lxd/) for Linux OS containerization (vs Docker application containers)
- `server` contains my markdown documents for securing Ubuntu 18.04 and 20.04, most have been abandoned for [hardending](https://github.com/konstruktoid/hardening) - Thomas Sjögren's aka konstruktoid's Ubuntu Hardening Project, but there are some documents that explain crap in the `home` directory
- `virtualbox` is obsolete at this point but kept in case
- `desktop` is actually about the Windows Subsystem for Linux and not one of the many flavors of Ubuntu Desktop
- 





### Common Crap

Common crap is crap that both home and professional users could potentially benefit from including:

*  centralized apt package cache [apt-cacher-ng](common/apt-cacher-ng.md) - download packages once instead of for each existing or new installation
*  centralized location for software and .iso [images](common/MaintainingLocalImages.md) - see above
*  centralized location for basic installation and operational scripts - need something? go here
*  centralized location for [Ansible](https://www.ansible.com) automation and deployment software

### Server Crap

-  Home Server
-  Administrative Servers
-  Professional Servers

### Desktops

Simple desktop crap. Including how to [quickly create a VirtualBox VM](virtualbox/UbuntuDesktopsVirtualBox.md) for anything you have an .iso image for.

# VirtualBox Labs

-  [LXD Lab](virtualbox/LXD_Lab.md)
-  [Docker Lab](virtualbox/Docker%20Lab.md)

# Neat Projects

## Github

-  [hardending](https://github.com/konstruktoid/hardening) - Thomas Sjögren's aka konstruktoid's Ubuntu Hardening Project
-  [ciab-remote-desktop](https://github.com/bmullan/ciab-remote-desktop) - Brian Mullins's Cloud in a Box (CIAB) Remote Desktop System
-  [mini-stack](https://github.com/containercraft/mini-stack) - Kathryn Morgan's Hypervisor Lab & Development Stack
-  [SnapRAID](https://github.com/amadvance/snapraid) - Andrea Mazzoleni's backup program for disk arrays; stores parity information of data and recovers from up to six disk failures

# Resources

Most of the contents in this repository come from pieces parts from the Internet and trial and failure in virtual machines from version 14.04 and beyond. I am certain I have missed numerous resources I do apologize for that.

-  [Galileo Labs Wiki](http://wiki.csgalileo.org/start)
-  [Ubuntu Installation Guide](https://help.ubuntu.com/lts/installation-guide/amd64/index.html)
-  [Aaron Toponce : Linux. GNU. Freedom.](https://pthree.org/)
