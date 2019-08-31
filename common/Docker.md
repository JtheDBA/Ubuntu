# Docker

-  *Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*
-  *Work in progress*

## Install

```Bash
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://download.docker.com/linux/ubuntu bionic stable"
. upd
. updone
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
sudo shutdown -r 1; exit
```

## Configure Storage

```Bash
sudo -i
systemctl stop docker
cp -au /var/lib/docker /var/lib/docker.bk
rm -rf /var/lib/docker/*
fdisk /dev/sdb
n
p
(default)
(default)
(default)
w
mkfs.ext4 /dev/sdb1
vi /etc/fstab
UUID=2f3b7b28-b180-4dfc-96cc-b7f6df7c4791 /var/lib/docker ext4 defaults 0 2
:x
mount /var/lib/docker
cp -au /var/lib/docker.bk/* /var/lib/docker/
cat > /etc/docker/daemon.json << FOOD
{
  "storage-driver": "overlay2"
}
FOOD
systemctl start docker
docker run hello-world
docker image ls
```

Note: I had to rerun the hello-world sometimes due to name resolution failure when docker attempted to load a remote image. I simply retried and eventually it works. If you know why - please share!

## Configure Networking

```
docker network create -d macvlan \
  --subnet=172.16.86.0/24 \
  --gateway=172.16.86.1 \
  -o parent=eth0 pub_net
```

# References

-  [https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04]
