#! /bin/bash
####
NDK=r17c
####
BUILD_LOG=true
####
APP=true
####
CONF="/data/local"
####
UPX=false
####
LIBUSB=false
###########################################
UPX_VERSION="3.95"
LIBUSB_VERSION="1.0.22"
OPENSSL_VERSION="1.1.0i"
SOURCEDIR="sources"
######
menu_api(){
[ -e $dir/patches/stapi/libwi.a ] && [ -e $dir/patches/stapi/stapi.patch ] && stapi="stapi "'Openbox_Xcruiser(experimental)'" off";
cmd=(dialog --separate-output --no-cancel --checklist "OSCam${TYPE} Rev:$FILE_REV" 16 60 10)
options=(14	"4.0 Ice Cream_Sandwich" off
	15	"4.0.3–4.0.4 Ice Cream Sandwich" off
	16	"4.1 Jelly Bean" off
	17	"4.2 Jelly Bean" off
	18	"4.3 Jelly Bean" off
	19	"4.4 KitKat" off
	21	"5.0 Lollipop" off
	22	"5.1 Lollipop" off
	23	"6.0 Marshmallow" off
	24	"7.0 Nougat" off
	26	"8.0 Oreo" off
	27	"8.1 Oreo" off
	28	"9.0 Pie" off
	Ax	"Amiko" off
	WP2	"WeTek Play 2" off
	$stapi)

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
for choice in $choices
do
    case $choice in
	Ax)
	BOX="Amiko"
	API="19"
	ABI="armeabi-v7a";
	CONF="/var/tuxbox/config"
	APP=false
	BUILD
	;;
	WP2)
	BOX="WeTek_Play_2"
	API="21"
	ABI="armeabi-v7a";
	APP=false
	BUILD
	;;
	stapi)
	BOX="Openbox_Xcruiser"
	API="21"
	ABI="armeabi-v7a";
	CONF="/data/plugin/oscam"
	APP=false
	BUILD
	rm -rf $sources/$cam
	;;
	14|15|16|17|18|19|21|22|23|24|26|27|28)
	API=$choice
	menu_abi
	;;
	esac
	done
clear && exit;
}
######
menu_abi(){
cmd=(dialog --separate-output --no-cancel --checklist "OSCam${TYPE} Rev:$FILE_REV (android-$API)" 11 60 10)
options=(armeabi-v7a "arm-linux-android" off
	 x86 "i686-linux-android" off
	 arm64 "aarch64-linux-android" off
	 x86_64 "x86_64-linux-android" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
for choice in $choices
do
    case $choice in
	armeabi-v7a)
	ABI="armeabi-v7a"
	BUILD
	;;
	x86)
	ABI="x86"
	BUILD
	;;
	arm64)
	ABI="arm64-v8a"
	BUILD
	;;
	x86_64)
	ABI="x86_64"
	BUILD
	;;
	esac
	done
clear;
}
######
[ ! -d $SOURCEDIR ] && mkdir -p $SOURCEDIR
dir=`pwd`
cd $SOURCEDIR
sources=`pwd`
######
export NCURSES_NO_UTF8_ACS=1;
#export LOCALE=UTF-8
progressbox="dialog --stdout ""$1"" --progressbox 15 70";
######
BUILD(){
ndk
make -C $sources/$cam config
CONF=$(dialog --no-cancel --title "Oscam config dir:" --inputbox $CONF 8 30 $CONF 3>&1 1>&2 2>&3)
[ -e $sources/config.mk ] && rm -rf $sources/config.mk
[ "$TYPE" = "-emu" ] && TYPE="-emu"$(grep -a "Version:" $sources/emu/VERSION | cut -d ' ' -f 2);
PLATFORM=android-$API
case $choice in A*|W*)PLATFORM=$BOX;;esac
if [ "$choice" = "stapi" ] ; then
PLATFORM=$BOX
patch -d $sources/$cam -p0 < $dir/patches/stapi/stapi.patch | $progressbox;
rej=($sources/$cam/*.rej)
[ -e "${rej[0]}" ] && dialog --title "ERROR!" --msgbox '                PATCH ERROR! '$cam'' 5 60 && exit;
fi
echo "DIR := $sources" >> $sources/config.mk
echo "CAM := $cam" >> $sources/config.mk
echo "PLATFORM := $PLATFORM" >> $sources/config.mk
echo "CONFDIR := $CONF" >> $sources/config.mk
echo "REV := ${REV}${TYPE}" >> $sources/config.mk
if $LIBUSB ; then
echo "usb := true" >> $sources/config.mk
usb
else
echo "usb := false" >> $sources/config.mk
fi
if [ "$cam" = "OSCam" ] ; then
echo "emu := false" >> $sources/config.mk
else
echo "emu := true" >> $sources/config.mk
fi
if [ "$choice" = "stapi" ] ; then
echo "stapi := true" >> $sources/config.mk
else
echo "stapi := false" >> $sources/config.mk
fi
ssl
[ ! -e $dir/packages/oscam.mk ] && wget -q -P $dir/packages -c https://raw.githubusercontent.com/su-mak/osebuild/master/packages/oscam.mk;
if $BUILD_LOG ; then
rm -rf $sources/build.log
$sources/android-ndk-$NDK/ndk-build APP_ABI=$ABI APP_PLATFORM=android-$API NDK_PROJECT_PATH=$sources NDK_LOG=1 APP_BUILD_SCRIPT=$dir/packages/oscam.mk 2>&1 | tee -a "$sources/build.log" | $progressbox;
else
$sources/android-ndk-$NDK/ndk-build APP_ABI=$ABI APP_PLATFORM=android-$API NDK_PROJECT_PATH=$sources APP_BUILD_SCRIPT=$dir/packages/oscam.mk 2>&1 | $progressbox
fi
if [ ! -e $sources/libs/$ABI/oscam ] ; then
dialog --title "WARNING!" --msgbox "\n                     BUILD ERROR!" 7 60
else
$UPX && UPX_ && $sources/upx-${UPX_VERSION}-amd64_linux/upx --brute $sources/libs/$ABI/oscam;
name="oscam-1.20-unstable_svn-${REV}${TYPE}-$PLATFORM"
ZIP | $progressbox;
dialog --title "$ABI" --msgbox "\n $name" 7 60
fi
}
######
ZIP(){
case $ABI in
armeabi-v7a)ARCH="arm";;
x86)ARCH="x86";;
arm64)ARCH="arm64";;
x86_64)ARCH="x86_64";;
esac
if $APP && [ -e $dir/application/cam.apk ] ; then
apkdir="$dir/application/storage/OSEbuild/installation"
mkdir -p $apkdir
zip -j $apkdir/oscam-$ABI.zip -xi $sources/libs/$ABI/oscam
cd $dir
zip -r $dir/$name-$ABI.zip -xi application
rm -rf $dir/application/storage
fi
zip -j $dir/$name-$ABI.zip -xi $sources/libs/$ABI/oscam
zip -j $dir/$name-$ABI.zip -xi $sources/$cam/README
$BUILD_LOG && zip -j $dir/$name-$ABI.zip -xi $sources/build.log;
[ "$choice" = "stapi" ] && [ -e $dir/patches/stapi/plugin.sh ] && . $dir/patches/stapi/plugin.sh;
rm -rf $sources/*obj*
rm -rf $sources/libs
}
######
ndk(){
FILE="android-ndk-$NDK-linux-x86_64.zip"
URL="https://dl.google.com/android/repository/$FILE"
if [ ! -d $sources/android-ndk-$NDK ] ; then
[ ! -e $sources/$FILE ] && SOURCE;
unzip $sources/$FILE | $progressbox;
fi
clear;
}
######
ssl(){
if [ ! -e $sources/usr/lib/android-$API/$ABI/libcrypto_static.a ] ; then
FILE="openssl-${OPENSSL_VERSION}.tar.gz"
URL="http://www.openssl.org/source/$FILE"
SOURCE
[ ! -d $sources/openssl-${OPENSSL_VERSION} ] && tar -xf $sources/$FILE;
make -C $sources/openssl-${OPENSSL_VERSION} crypto/include/internal/bn_conf.h > /dev/null
make -C $sources/openssl-${OPENSSL_VERSION} crypto/include/internal/dso_conf.h > /dev/null
make -C $sources/openssl-${OPENSSL_VERSION} crypto/buildinf.h > /dev/null
make -C $sources/openssl-${OPENSSL_VERSION} include/openssl/opensslconf.h > /dev/null
[ ! -e $dir/packages/openssl.mk ] && wget -q -P $dir/packages -c https://raw.githubusercontent.com/su-mak/osebuild/master/packages/openssl.mk;
$sources/android-ndk-$NDK/ndk-build APP_ABI=$ABI APP_PLATFORM=android-$API NDK_PROJECT_PATH=$sources APP_BUILD_SCRIPT=$dir/packages/openssl.mk 2>&1 | $progressbox
[ ! -d $sources/usr/lib/android-$API/$ABI ] && mkdir -p $sources/usr/lib/android-$API/$ABI;
mv $sources/obj/local/$ABI/libcrypto_static.a $sources/usr/lib/android-$API/$ABI/libcrypto_static.a
[ ! -d $sources/usr/include ] && mkdir -p $sources/usr/include;
cp -r $sources/openssl-${OPENSSL_VERSION}/include/openssl $sources/usr/include
rm -rf $sources/openssl-${OPENSSL_VERSION}
rm -rf $sources/*obj*
fi
}
######
usb(){
if [ ! -e $sources/usr/lib/android-$API/$ABI/libusb1.0_static.a ] ; then
FILE="libusb-${LIBUSB_VERSION}.tar.bz2"
URL="https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/$FILE"
SOURCE
[ ! -d $sources/libusb-${LIBUSB_VERSION} ] && tar -jxf $sources/$FILE;
[ ! -d $sources/libusb-${LIBUSB_VERSION}/libusb-1.0 ] && ln -s $sources/libusb $sources/libusb-${LIBUSB_VERSION}/libusb-1.0;
[ ! -e $dir/packages/libusb.mk ] && wget -q -P $dir/packages -c https://raw.githubusercontent.com/su-mak/osebuild/master/packages/libusb.mk;
$sources/android-ndk-$NDK/ndk-build APP_ABI=$ABI APP_PLATFORM=android-$API NDK_PROJECT_PATH=$sources APP_BUILD_SCRIPT=$dir/packages/libusb.mk 2>&1 | $progressbox
[ ! -d $sources/usr/lib/android-$API/$ABI ] && mkdir -p $sources/usr/lib/android-$API/$ABI;
mv $sources/obj/local/$ABI/libusb1.0_static.a $sources/usr/lib/android-$API/$ABI/libusb1.0_static.a
[ ! -d $sources/usr/include/libusb-1.0 ] && mkdir -p $sources/usr/include/libusb-1.0;
cp $sources/libusb-${LIBUSB_VERSION}/libusb/libusb.h $sources/usr/include/libusb-1.0/
rm -rf $sources/libusb-${LIBUSB_VERSION}
rm -rf $sources/*obj*
fi
}
######
UPX_(){
if [ ! -d $sources/upx-${UPX_VERSION}-amd64_linux/upx ] && $UPX ; then
FILE="upx-${UPX_VERSION}-amd64_linux.tar.xz"
URL="https://github.com/upx/upx/releases/download/v${UPX_VERSION}/$FILE"
SOURCE
tar -xf $sources/$FILE
fi
clear;
}
######
SOURCE(){
[ ! -e $sources/$FILE ] && wget -P $sources -c --progress=bar:force "$URL" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "$FILE" 6 50;
[ ! -e $sources/$FILE ] && dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n '$URL'' 7 50 && clear && exit;
}
######
rev() {
if [ ! -e $sources/$cam ] ; then
REV=$(dialog --no-cancel --title "Online SVN:$REV_EMU ($SVN_MIN to $REV_EMU)" --inputbox "$REV" 8 30 "$REV_EMU" 3>&1 1>&2 2>&3)
else
dialog --title "$cam UPDATE" --backtitle "" --yesno "Online SVN ('$REV_EMU') = Local SVN ('$FILE_REV')" 7 50
response=$?
case $response in
   0) 
REV=$(dialog  --no-cancel --title "Local svn:$FILE_REV  ($SVN_MIN to $REV_EMU)" --inputbox "$REV" 8 35 "$REV_EMU" 3>&1 1>&2 2>&3)
;;
1)menu_api;;
esac
fi
if [ "$REV" -ge $SVN_MIN ] && [ "$REV" -le "$REV_EMU" ] ; then
null="null"
else
rev
fi
if [ -e $sources/$cam  ] ; then
rm -rf $sources/$cam 
fi
if [ "$cam" = "OSCam_Emu" ] ; then
svn co -r $REV $SVN_EMU emu | $progressbox
REV=$(grep -a " Makefile" emu/oscam-emu.patch | grep -a "revision" | cut -c24-28)
svn co -r $REV $SVN_SOURCE $sources/$cam | $progressbox
else
svn co -r $REV $SVN_SOURCE $sources/$cam | $progressbox
REV=$(svn info $sources/$cam | grep Revision | cut -d ' ' -f 2)
fi
FILE_REV=$(svn info $sources/$cam | grep Revision | cut -d ' ' -f 2)
[ "$cam" = "OSCam_Emu" ] && patch -d $sources/$cam -p0 < $sources/emu/oscam-emu.patch | $progressbox;
menu_api
}
####
OSCAM() {
SVN_SOURCE="http://www.streamboard.tv/svn/oscam/trunk"
REV_EMU=$(svn info $SVN_SOURCE | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="11438";
TYPE="";
cam="OSCam";
[ -e $sources/$cam ] && FILE_REV=$(svn info $sources/$cam | grep Revision | cut -d ' ' -f 2);
rev
}
####
OSCAM_EMU() {
SVN_EMU="https://github.com/oscam-emu/oscam-emu/trunk"
SVN_SOURCE="http://www.streamboard.tv/svn/oscam/trunk"
REV_EMU=$(svn info $SVN_EMU | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="1867";
TYPE="-emu";
cam="OSCam_Emu";
[ -e $sources/emu ] && FILE_REV=$(svn info $sources/emu | grep Revision | cut -d ' ' -f 2);
rev
}
OSCAM_PATCHED() {
SVN_SOURCE="https://github.com/oscam-emu/oscam-patched/trunk"
REV_EMU=$(svn info $SVN_SOURCE | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="1595";
TYPE="-patched";
cam="OSCam_patched";
[ -e $sources/$cam ] && FILE_REV=$(svn info $sources/$cam | grep Revision | cut -d ' ' -f 2);
rev
}
######
menu(){
selected=$(dialog --stdout --clear --colors --backtitle $0 --title "" --menu "" 9 60 8 \
	1	"Oscam" \
	2	"Oscam-emu" \
	4	"Oscam-patched");
case $selected in
	1) OSCAM ;;
	2) OSCAM_EMU ;;
	4) OSCAM_PATCHED ;;
	esac
clear && exit;
}
##############
case $1 in
h|-h|--h|help|-help|--help|Help|HELP)
MACHINE=`uname -o`
MACHINE_TYPE=`uname -m`
if [ $MACHINE_TYPE = 'x86_64' ] ; then
case "$MACHINE" in
GNU/Linux*)
echo "-----------------------------"
echo "Build:     "
echo "	Oscam-patched"
echo "-----------------------------"
echo "PLATFORM:"
echo "	ANDROID:arm,x86,arm64,x86_64"
echo "-----------------------------"
echo "Packages required:"
echo "		dialog subversion gcc make zip"
echo "-----------------------------"
echo "   $0"
echo "-----------------------------"
;;
*)
echo "this is not linux operating system"
;;
esac
else
echo "this is not linux x86_64 operating system"
fi
exit 0;
;;
esac
##############
menu
##############
exit;

