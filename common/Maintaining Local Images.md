# Maintaining Local Images

The `zsync` package available in most Debian distributions can be used to combine one or more source .iso files and download only the differences and missing blocks from a remote site for an updated .iso file.

I have used `zsync` for years and it usually saves about 60% of download bandwidth for version upgrades and 40 to 50% for upgrades to new releases of operating systems.

I keep all of my .iso images in a shared folder available to multiple systems and on my administrative home server running the apt-cache-ng server. The local .iso images can be used to pre-populate the apt-cache-ng local cache.

## Installing packages

```Bash
sudo apt install transmission-cli zsync
```

`zsync` accepts one or more input files using the `-i name` arguments and will combine all specified input files then requires the last argument to be the remote location of the .zsync file used to determine what blocks need downloaded to make the new .iso image complete.

`transmission-cli` the command line version of Bittorrent but any Bittorrent client can be used (I use the one in Download Station on my Synology NAS). Bittorrent helps speed up downloads and contributes upload bandwidth for others joining the torrent swarm versus `zsync` connecting to one remote server.

## Updating Local .iso Images

To update all local .iso images from 18.04.2 to 18.04.3 saved about 5GB of download bandwidth by using `zsync` and the `transmission-cli` Bittorrent client.

```Bash
cd /media/local/Software/ISO
zsync -i ubuntu-18.04.2-desktop-amd64.iso http://releases.ubuntu.com/18.04.3/ubuntu-18.04.3-desktop-amd64.iso.zsync
```

Optional step; if the percentage of the completed .iso on hand there is the option to Ctrl-C to stop `zsync` and finish the first desktop (or any image) using bittorrent.

```Bash
mv ubuntu-18.04.3-desktop-amd64.iso.part ubuntu-18.04.3-desktop-amd64.iso
transmission-cli -d 4096 -u 320 -ep -m -w ./ http://releases.ubuntu.com/18.04.3/ubuntu-18.04.3-desktop-amd64.iso.torrent
```

When the desktop image has finished downloading it can be used as input to other .iso images for other releases of Ubuntu

```Bash
zsync -i ubuntu-18.04.2-live-server-amd64.iso -i ubuntu-18.04.3-desktop-amd64.iso http://releases.ubuntu.com/18.04.3/ubuntu-18.04.3-live-server-amd64.iso.zsync
zsync -i ubuntu-mate-18.04.2-desktop-amd64.iso -i ubuntu-18.04.3-desktop-amd64.iso http://cdimage.ubuntu.com/ubuntu-mate/releases/18.04.3/release/ubuntu-mate-18.04.3-desktop-amd64.iso.zsync
zsync -i xubuntu-18.04.2-desktop-amd64.iso -i ubuntu-18.04.3-desktop-amd64.iso http://cdimage.ubuntu.com/xubuntu/releases/18.04.3/release/xubuntu-18.04.3-desktop-amd64.iso.zsync
zsync -i kubuntu-18.04.2-desktop-amd64.iso -i ubuntu-18.04.3-desktop-amd64.iso http://cdimage.ubuntu.com/kubuntu/releases/18.04.3/release/kubuntu-18.04.3-desktop-amd64.iso.zsync
```

Any combination of the above can be used to update and .iso to a newer version including beta and new versions of Ubuntu or any OS that provides a .zsync file for downloading.
