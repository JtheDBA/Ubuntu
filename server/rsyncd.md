

```
vi /etc/rsyncd.conf
# /etc/rsyncd: configuration file for

pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
address = 192.168.10.99
uid = joel
gid = joel
max connections = 4
ignore nonreadable = yes
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
reverse lookup = no
read only = false
write only = false

[chia]
path = /srv/u01/chia
comment = Chia plot storage
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2 *.plot

[chia2]
path = /srv/u02/chia
comment = Chia plot storage 4
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2 *.plot

cp /lib/systemd/system/rsync.service /etc/systemd/system/rsync.service
systemctl restart rsync
```