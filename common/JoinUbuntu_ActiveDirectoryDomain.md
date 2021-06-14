# Join Ubuntu to Active Directory Domain

Status: *untested*

## Realmd

[Join in Windows Active Directory Domain with Realmd](https://www.server-world.info/en/note?os=Ubuntu_18.04&p=realmd)


```Bash
sudo -i
apt -y install realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit
sed -i.bak -e '/nameservers/{n;s/addresses: \[.*.\]/addresses: [AD, AD]/}' /etc/netplan/*.yaml
netplan apply
```

```Bash
realm discover 
realm join SRV.WORLD
Password for Administrator:     # AD Administrator password
# verify it's possible to get an AD user info or not
root@dlp:~# id FD3S01\\Serverworld
uid=409601000(serverworld@srv.world) gid=409600513(domain users@srv.world) groups=409600513(domain users@srv.world)
# verify it's possible to switch to an AD user or not
root@dlp:~# su - FD3S01\\Serverworld
No directory, logging in with HOME=/
serverworld@srv.world@dlp:/$     # just switched
[3]	If you'd like to omit domain name for AD user, configure like follows.
root@dlp:~# vi /etc/sssd/sssd.conf
# line 16: change
use_fully_qualified_names = False
root@dlp:~# systemctl restart sssd
root@dlp:~# id Administrator
uid=409600500(administrator) gid=409600513(domain users) groups=409600513(domain users),
409600518(schema admins),409600572(denied rodc password replication group),
409600519(enterprise admins),409600512(domain admins),409600520(group policy creator owners)
```