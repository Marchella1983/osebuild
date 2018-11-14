## Build OSCam for Android
+ Linux system

| Build | |
| ------ | ------ |
| OSCam | http://www.streamboard.tv/oscam/ |
| OSCam Emu | https://github.com/oscam-emu/oscam-emu |
| OSCam-patched | https://github.com/oscam-emu/oscam-patched |

###### Packages install:
```sh
apt-get install dialog subversion gcc make zip
```
###### Install:
```sh
svn co https://github.com/su-mak/osebuild/trunk osebuild
cd osebuild
./build.sh -help
```
or
```sh
mkdir osebuild
cd osebuild
wget https://raw.githubusercontent.com/su-mak/osebuild/master/build.sh
chmod 755 build.sh
./build.sh -help
```
#### Building from Source
```sh
./build.sh
```
