# SWAKES Media Server

*Let's Build an Automated Media Server!*

- [Part 1 - OS - An Overview then OS and Docker Setup](https://blog.swakes.co.uk/automated-media-box-part1/)
- [Part 2 - Download - Transmission, Sonarr and the Crew](https://blog.swakes.co.uk/automated-media-box-part2/)
- [Part 3 - Media - Setting up Plex, Tautulli and Ombi](https://blog.swakes.co.uk/automated-media-box-part3/)

*Standard disclaimer: do not assume I know what I am doing or any instructions below should be used outside of personal experimentation and learning. All comments are my own and do not reflect the thoughts or direction of my employer, family, friends, favorite television and radio station or anything else.*

*Work in progress*

## Clone the Base Ubuntu Server

````
SET VM=SWAKES
SET VG=Ubuntu Servers
SET BF=%VDID%\%VG%
%VB% clonevm "Ubuntu Server 18.04" --snapshot "BASE1804_01" --options link --name "%VM%" --basefolder "%BF%" --register
%VB% modifyvm "%VM%" --groups "/%VG%"
%VB% modifyvm "%VM%" --memory 6144
FOR %A IN (1 2) DO %VB% createhd --filename "%BF%\%VM%\UBU1804_SATA%A.vdi" --size 12000%A
FOR %A IN (1 2) DO %VB% storageattach "%VM%" --storagectl "SATA" --port %A --type hdd --medium "%BF%\%VM%\UBU1804_SATA%A.vdi" --mtype normal
%VB% sharedfolder add "%VM%" --name "download" --hostpath "T:\Users\Joel\Downloads" --automount
%VB% sharedfolder add "%VM%" --name "video" --hostpath "U:\Video" --automount
%VB% startvm "%VM%"
```

```
cd ~
sudo apt install -y build-essential module-assistant
sudo m-a prepare
sudo mkdir /media/cdrom
cat > vbox << FOOD
sudo mount /dev/cdrom /media/cdrom
sudo /media/cdrom/VBoxLinuxAdditions.run
sudo shutdown -r now
FOOD
. vbox
```

```
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common  unzip
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}
sudo shutdown -r now
```

https://docs.docker.com/storage/storagedriver/btrfs-driver/

sudo systemctl stop docker
sudo cp -au /var/lib/docker /var/lib/docker.bk
sudo mkfs.btrfs /dev/sdb
sudo rm -rf /var/lib/docker/*
echo "/dev/sdb /var/lib/docker btrfs defaults 0 1" | sudo tee -a /etc/fstab
sudo mount /var/lib/docker
sudo cp -au /var/lib/docker.bk/* /var/lib/docker/

Configure Docker to use the btrfs storage driver. This is required even though /var/lib/docker/ is now using a Btrfs filesystem. 
Edit or create the file /etc/docker/daemon.json. If it is a new file, add the following contents. 
If it is an existing file, add the key and value only, being careful to end the line with a comma if it is not the final line before an ending curly bracket (}).

{
  "storage-driver": "btrfs"
}


```
sudo systemctl status docker
docker volume create portainer_data
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer --restart unless-stopped

http://192.168.0.42:9000
```