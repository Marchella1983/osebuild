# OSEbuild
+ Linux system
+ Build OSCam for Android

| Build | |
| ------ | ------ |
| OSCam | http://www.streamboard.tv/oscam/ |
| OSCam Modern | http://www.streamboard.tv/oscam-addons/browser/modern |
| OSCam Emu | https://github.com/oscam-emu/oscam-emu |

###### Packages install:
```sh
apt-get install dialog subversion gcc make zip python pkg-config
```
###### Install:
```sh
svn co https://github.com/su-mak/osebuild/branches/old osebuild
cd osebuild
./OSEbuild.sh -help
```
or
```sh
mkdir osebuild
cd osebuild
wget https://raw.githubusercontent.com/su-mak/osebuild/old/OSEbuild.sh
chmod 755 OSEbuild.sh
./OSEbuild.sh -help
```
#### Building from Source
```sh
./OSEbuild.sh
```
---
