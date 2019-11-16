# Ubuntu 18.04 Shell in Windows 10

>Ubuntu 18.04 on Windows allows one to use Ubuntu Terminal and run Ubuntu command line utilities including bash, ssh, git, apt and many more.

This uses the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about) and allows Windows hosts to run supported distributions of Linux in non-GUI mode (i.e. a shell, prompt, etc.).
There is also a [GitHub](https://github.com/MicrosoftDocs/WSL) and if you are feeling daring [WSL2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-index).

Personal notes:

-  Installed and operational on Windows 10 and Server 2019
-  Windows 10 disks by letter are mounted under `/mnt` i.e `/mnt/c`
-  `apt` install and upgrade are available and can use `apt-cacher-ng`
-  you can install non GUI applications
-  instead of `shutdown -h now` just `exit`
-  you can run DOS / Command Prompt applications from the shell
-  `wsl.exe` executes from a Windows command prompt and interacts with the subsystem [Command Reference](https://docs.microsoft.com/en-us/windows/wsl/reference)
-  Shift-Right Click in explorer offers an *Open in Linux Shell* option
-  `snapd` and snaps are not supported yet (I tried to install the PowerShell snap as a larf)

## Steps

Start [HERE](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

1. Before installing any Linux distros for WSL, you must ensure that the "Windows Subsystem for Linux" optional feature is enabled. Open PowerShell as Administrator and run `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux` and restart your computer when prompted.
2. Install from the Windows Store

## No Windows Store?

>There are several scenarios in which you may not be able (or want) to, install WSL Linux distros via the Microsoft Store. Specifically, you may be running a Windows Server or Long-Term Servicing (LTSC) desktop OS SKU that doesn't support Microsoft Store, or your corporate network policies and/or admins to not permit Microsoft Store usage in your environment.

*Or you are lazy like me and like copy pasta:* Open PowerShell as Administrator and run:

```PowerShell
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu1804.appx -UseBasicParsing
Add-AppxPackage .\Ubuntu1804.appx
```

## FAQ

[How Do I Mount Other Windows Drives?](https://superuser.com/questions/1114341/windows-10-ubuntu-bash-shell-how-do-i-mount-other-windows-drives

Good news, it is now possible to mount USB media (including formatted as FAT) and network shares with drvfs on Windows 10: Mount removable media: (e.g. D:)

`sudo mkdir /mnt/d`
`sudo mount -t drvfs D: /mnt/d`

To safely unmount

`sudo umount /mnt/d`

You can also mount network shares without smbfs:

`sudo mount -t drvfs '\\server\share' /mnt/share`

*Note; at some point you have to have mounted the drive and saved your credentials for this to work - I think - at least that is what I had to do*
