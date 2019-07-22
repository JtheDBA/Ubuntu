if ! (findmnt /mnt/cifs/144/TODO); then mount.cifs //192.168.0.144/_TODO /mnt/cifs/144/TODO; fi
if ! (findmnt /mnt/cifs/144/Inbox); then mount.cifs //192.168.0.144/Inbox /mnt/cifs/144/inbox; fi
if ! (findmnt /mnt/cifs/144/_TODO2); then mount.cifs //192.168.0.144/_TODO2 /mnt/cifs/144/TODO2; fi
if ! (findmnt /mnt/cifs/144/Stuff); then mount.cifs //192.168.0.144/Stuff /mnt/cifs/144/stuff; fi

