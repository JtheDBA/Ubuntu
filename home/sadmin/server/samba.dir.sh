cat > /root/.smbcredentials << FOOD
username=joel
password=
FOOD
chmod 700 /root/.smbcredentials
mkdir -p /mnt/cifs/080/{TODO,DONE}
mkdir -p /mnt/cifs/129/TODO
mkdir -p /mnt/cifs/130/{archive,download,image,music,photo,video}
mkdir -p /mnt/cifs/144/{TODO,TODO2,stuff,inbox}
chmod -R 777 /mnt/cifs
chown -R nobody:nogroup /mnt/cifs

