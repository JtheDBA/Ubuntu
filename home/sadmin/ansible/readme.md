# Ansible

## Installation

[How To Install and Configure Ansible on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-20-04).

``` Bash
cd ~
. install-ansible
```

Above assumes the `/home/sadmin` directory has been populated. Creates some handy aliases:

-  apb='ansible-playbook -K '
-  apbl='ansible-playbook -K -l ' to run playbook with list
-  apbi='ansible-playbook -K -i ' to run playbook with inventory file

## Playbooks

-  data_vg-create.yaml - create LVM volume group `data_vg` on default device `/dev/sdc`
-  install-docker.yaml - install Docker CE
-  *install-kubernetes.yaml* - experimenting
-  lvm-docker.yaml - create and format logical volumes for Docker
-  reboot.yaml - reboot or restart machines
-  shutdown.yaml - shutdown servers; useful when updating dozens of temporary machines or when a tornado changes direction and things need shutdown NOW 
-  update.yaml - update package lists and upgrade distribution only downloading updates, not installing them, serially to not overwhelm the apt-cache
-  updwithreboot.yaml - update package lists and upgrade distribution, restarting machine if needed

## Quick Lines

``` Bash
ansible lxdhosts -m ping
ansible all -a "df -h"
ansible-playbook -K -l microk8-master,media-server,cbj-cannon update.yaml
ansible-playbook -K updwithreboot.yaml
```

## Helpful Links

-  [Playbook Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
-  [Using Variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)