# apt-cacher-ng

Apt-Cacher NG is a caching proxy for software packages which are downloaded by Unix/Linux system distribution mechanisms from mirror servers accessible via HTTP.

With 3 physical and dozens of virtual computers I save roughly 4 GB of traffic per month (average 63% hit rate; remember I have 7 different test desktop distributions that contribute to the "lower" hit rate).

## pre Install

### UFW

If you use the Uncomplicated Firewall i.e. UFW create an "application" file and set appropriate allow from rules. Customize the allow from the subnets you use or tighten up the existing ones.

```Bash
cat > /etc/ufw/applications.d/apt-cacher-ng << FOOD
[AptCacherNG]
title=Caching proxy for .deb software packages
description=Apt-Cacher NG is a caching proxy for .deb software packages
ports=3142/tcp
FOOD
ufw app update AptCacherNG
ufw allow from 10.0.0.0/8 to any app AptCacherNG
ufw allow from 172.16.0.0/12 to any app AptCacherNG
ufw allow from 192.168.0.0/16 to any app AptCacherNG
ufw deny from any to any app AptCacherNG
ufw reload
```

## Install

Note; if installing from "Mini" everything should be up to date and some steps will fail with "cannot stat '/var/cache/apt/archives/*.deb': No such file or directory"

```Bash
sudo -i
apt install -y apt-cacher-ng lynx
echo 'Acquire::http { Proxy "http://127.0.0.1:3142"; };' | tee /etc/apt/apt.conf.d/01apt-cacher-ng-proxy
apt update
test -x /var/cache/apt-cacher-ng/_import || mkdir -p -m 2755 /var/cache/apt-cacher-ng/_import
mv -uf /var/cache/apt/archives/*.deb /var/cache/apt-cacher-ng/_import/
chown -R apt-cacher-ng.apt-cacher-ng /var/cache/apt-cacher-ng/_import
lynx http://127.0.0.1:3142/acng-report.html?doImport=Start+Import#bottom
apt full-upgrade -y
```

## Optional Steps

If you have one or more .iso images local or available to the server they can be imported into the apt-cacher-ng cache.

```Bash
cd /dir/where/all/the/isos/are/stored
for FOO in `ls *buntu*iso`
do
mount -o loop ${FOO} /var/cache/apt-cacher-ng/_import
lynx http://127.0.0.1:3142/acng-report.html?doImport=Start+Import#bottom
umount /var/cache/apt-cacher-ng/_import
done
```

## SSL/TLS

[Read This First](https://www.unix-ag.uni-kl.de/~bloch/acng/html/howtos.html#ssluse) !!!

Since I am extremely lazy I just change all https references to http and everything so far has worked. Again, I am lazy and like to use the cache. Tested and working with both docker-ce and opera.

# References

-  [Apt-Cacher-NG User Manual](https://www.unix-ag.uni-kl.de/~bloch/acng/html/index.html)
-  [Uncomplicated Firewall](https://wiki.archlinux.org/index.php/Uncomplicated_Firewall)