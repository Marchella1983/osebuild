#! /bin/bash
#################################################
#                OSEbuild Android
#################################################
# Configure where we can find things here
#################################################
#          on&off
PLUS_MENU="on"
BUILD_LOG="on"
BACKUP="on"
#
#################################################
# When editing, delete the toolchains folder!
#################################################
#             ANDROID NDK
###                 on&off
ANDROID_NDK_AU_DOWNLOAD="on"
ANDROID_NDK_REV="r13b"  #... to r18b, 32bit"r10e"
### ANDROID_NDK_AU_DOWNLOAD = off ##
ANDROID_NDK_ROOT=$PWD/../android-ndk
#################################################
#
ANDROID_API_LEVEL="16"
TOOLCHAIN_VERSION="4.9"
####
OPENSSL_VERSION="1.1.0i"
##############
LIBUSB_ANDROID="on";
LIBUSB_VERSION="1.0.22"
##############
ANDROID_APP="on"
####
PCSC_ANDROID="on";
PCSC_LITE_VERSION="1.8.22"
PCSC_APP_DIR="/data/data/osebuild.cam/files"
##############
CCID_ANDROID="on"
CCID_VERSION="1.4.28"
#################################################
# The Ultimate Packer for eXecutables
#      https://upx.github.io
#
UPX="off"
UPX_VERSION="3.94"
#################################################
# end ###########################################
#################################################
SOURCEDIR="tmp"
###############################################################
progressbox="dialog --stdout ""$1"" --progressbox 15 70";
[ ! -e $SOURCEDIR ] && mkdir -p $SOURCEDIR;
ddir=`pwd`;
cd $SOURCEDIR
rdir=`pwd`;
btdir="$rdir/toolchains/backup";
date=`date`
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} = 'x86_64' ] ; then
M_TYPE="x86_64"
else
M_TYPE="x86"
fi
CONF="/usr/local/etc";
####
NDK_REV=${ANDROID_NDK_REV:1:2};
android(){
if [ "$ANDROID_API_LEVEL" -ge "16" ] ; then
PIE="-fPIE"
PIE_="-fPIE -pie"
else
PIE=""
PIE_=""
fi
CFLAGS="-g -DANDROID -D__ANDROID_API__=${ANDROID_API_LEVEL} -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes $CFLAGS $PIE"
LDFLAGS="-Wl,--build-id -Wl,--warn-shared-textrel -Wl,--fatal-warnings -Wl,-s $LDFLAGS $PIE_"
case "$ARCH" in
arm)
Toolchain="arm-linux-androideabi"
PLATFORM="arm-linux-androideabi"
;;
x86)
Toolchain="x86"
PLATFORM="i686-linux-android"
;;
mips)
Toolchain="mipsel-linux-android"
PLATFORM="mipsel-linux-android"
;;
arm64)
Toolchain="aarch64-linux-android"
PLATFORM="aarch64-linux-android"
;;
 x86_64)
Toolchain="x86_64"
PLATFORM="x86_64-linux-android"
;;
mips64)
Toolchain="mips64el-linux-android"
PLATFORM="mips64el-linux-android"
;;
esac
case "$ANDROID_API_LEVEL" in
9)PLATFORM_VERSIONS="2.3–2.3.2_Gingerbread";;
12)PLATFORM_VERSIONS="3.1_Honeycomb";;
13)PLATFORM_VERSIONS="3.2_Honeycomb";;
14)PLATFORM_VERSIONS="4.0_Ice_Cream_Sandwich";;
15)PLATFORM_VERSIONS="4.0.3–4.0.4_Ice_Cream_Sandwich";;
16)PLATFORM_VERSIONS="4.1_Jelly_Bean";;
17)PLATFORM_VERSIONS="4.2_Jelly_Bean";;
18)PLATFORM_VERSIONS="4.3_Jelly_Bean";;
19)PLATFORM_VERSIONS="4.4_KitKat";;
20)PLATFORM_VERSIONS="Wear_4.4_KitKat";;
21)PLATFORM_VERSIONS="5.0_Lollipop";;
22)PLATFORM_VERSIONS="5.1_Lollipop";;
23)PLATFORM_VERSIONS="6.0_Marshmallow";;
24)PLATFORM_VERSIONS="7.0_Nougat";;
25)PLATFORM_VERSIONS="7.1_Nougat";;
26)PLATFORM_VERSIONS="8.0_Oreo";;
27)PLATFORM_VERSIONS="8.1_Oreo";;
28)PLATFORM_VERSIONS="9.0_Pie";;
*)PLATFORM_VERSIONS="API_level_${ANDROID_API_LEVEL}";;
esac
tcdir="$rdir/toolchains/Android_${PLATFORM_VERSIONS}-${ARCH}"
Build="Android_${PLATFORM_VERSIONS}-${ARCH}"
usb=""
pcsc=""
[ "$NDK_REV" -ge "15" ] && LIBUSB_ANDROID="off";
[ "$LIBUSB_ANDROID" = "on" ] && usb="libusb "USB_devices" off";
[ "$ANDROID_APP" = "on" ] && [ "$LIBUSB_ANDROID" = "on" ] && [ "$PCSC_ANDROID" = "on" ] && pcsc="pcsc "PCSC_readers" off";
ANDROID_NDK
CONFIG
OSCAM_MAKE
CFLAGS="";
LDFLAGS="";
EXTRA_LIBS="";
}
####
CONFIG(){
CROSS=$CROSS;
cd $rdir/$CAM_F
REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2)
N_SSL="";
I_SSL="";
N_LIBUSB="";
I_LIBUSB="";
N_PCSC="";
I_PCSC="";
I_USE="";
N_USE="";
case $selected in A*|v*.x)Build=$BOX;;
stapi)Build="$BOX"
if [ -e $ddir/patches/stapi/libwi.a ] || [ -e $tcdir/sysroot/usr/lib/libwi.a ] ; then
I_USE=" USE_STAPI=1 AL_MODEL=supremo EXTRA_FLAGS=-Dsupremo"
N_USE="-stapi";
[ ! -e $rdir/$CAM_F/stapi.patch ] && cp $ddir/patches/stapi/stapi.patch $rdir/$CAM_F/ && cd $rdir/$CAM_F && patch -p0 < stapi.patch | $progressbox;
[ -e $rdir/$CAM_F/*.rej ] && dialog --title "ERROR!" --msgbox '                  PATCH ERROR! '$CAM_F'' 5 60 && exit;
fi
;;
esac
cmd=(dialog --separate-output --no-cancel --checklist "$CAM_F $REV: ($Build: $ABI)" 16 60 10)
options=(conf_dir: "$CONF" off	
	$usb
	$pcsc
	ssl "SSL" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
for choice in $choices
do
	case $choice in
	conf_dir:)
	CONF=$(dialog --no-cancel --title "Oscam config dir:" --inputbox $CONF 8 30 $CONF 3>&1 1>&2 2>&3)
	;;
	ssl)
	N_SSL="-ssl";
	I_SSL=" USE_SSL=1";
	;;
	libusb)
	N_LIBUSB="-libusb";	
	I_LIBUSB=" USE_LIBUSB=1 LIBUSB_LIB=${tcdir}/sysroot/usr/lib/libusb-1.0.a";
	;;
	pcsc)
	N_PCSC="-pcsc"
	I_PCSC=" USE_PCSC=1 PCSC_LIB=${tcdir}/sysroot/usr/lib/libpcsclite.a";
	;;
	esac
done
make config
[ "$NDK_REV" -ge "15" ] && ./config.sh --disable CARDREADER_DB2COM; #READER_NAGRA_MERLIN;
./config.sh --disable CLOCKFIX
}
####
OSCAM_MAKE(){
[ "$NP" = "-emu" ] && NP="-emu"$(grep -a "Version:" $rdir/emu/VERSION | cut -d ' ' -f 2);
CAMNAME=oscam-1.20-unstable_svn-${REV}${NP}-${Build}${N_SSL}${N_LIBUSB}${N_PCSC}${N_USE}
SMARGONAME=list_smargo-1.20-unstable_svn-${REV}${NP}-${Build}${N_SSL}${N_LIBUSB}${N_PCSC}${N_USE}
if [ "$N_LIBUSB" = "-libusb" ] ; then
smargo=" LIST_SMARGO_BIN=Distribution/${SMARGONAME}";
else
smargo="";
fi
if [ "$BUILD_LOG" = "on" ] ; then
echo -e "-------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
echo -e "             $0">>$rdir/$CAM_F/Distribution/build.log;
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
echo -e "OSCAM$NP-Rev:$FILE_REV-$Build ">>$rdir/$CAM_F/Distribution/build.log;
echo -e "$Build $ABI ">>$rdir/$CAM_F/Distribution/build.log;
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
#echo -e "make android-arm CROSS=${CROSS} USE_LIBCRYPTO=1 OSCAM_BIN=Distribution/${CAMNAME}${smargo} CONF_DIR=${CONF} CFLAGS="${CFLAGS}" "${LDFLAGS}" EXTRA_LIBS="${EXTRA_LIBS}"${I_SSL}${I_LIBUSB}${I_PCSC}${I_USE}">>$rdir/$CAM_F/Distribution/build.log;
echo -e "Enabled configuration --------------------">>$rdir/$CAM_F/Distribution/build.log;
./config.sh -s 2>&1 | tee -a "$rdir/$CAM_F/Distribution/build.log" | $progressbox
make android-arm CROSS=${CROSS} USE_LIBCRYPTO=1 OSCAM_BIN=Distribution/${CAMNAME}${smargo} CONF_DIR=${CONF} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" EXTRA_LIBS="${EXTRA_LIBS}"${I_SSL}${I_LIBUSB}${I_PCSC}${I_USE} 2>&1 |tee -a "$rdir/$CAM_F/Distribution/build.log" | $progressbox
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
echo -e "$date">>$rdir/$CAM_F/Distribution/build.log;
echo -e "------------------------------------------">>$rdir/$CAM_F/Distribution/build.log;
else
make android-arm CROSS=${CROSS} USE_LIBCRYPTO=1 OSCAM_BIN=Distribution/${CAMNAME}${smargo} CONF_DIR=${CONF} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" EXTRA_LIBS="${EXTRA_LIBS}"${I_SSL}${I_LIBUSB}${I_PCSC}${I_USE} 2>&1 | $progressbox
fi
sleep 2
if [ ! -e $rdir/$CAM_F/Distribution/$CAMNAME ] ; then
dialog --title "WARNING!" --msgbox "\n                     BUILD ERROR!" 7 60
else
if [ "$UPX" = "on" ] && [ -e $rdir/$CAM_F/Distribution/$CAMNAME ] ; then
UPX_
$btdir/upx-${UPX_VERSION}-${UPX_TYPE}_linux/upx --brute $rdir/$CAM_F/Distribution/$CAMNAME -o $rdir/$CAM_F/Distribution/$CAMNAME-upx
fi
ZIP | $progressbox
dialog --title "$REV${NP}-$Build" --msgbox "\n $CAMNAME" 7 60
fi
}
####
ZIP(){
zip -j $ddir/$CAMNAME.zip -xi $rdir/$CAM_F/Distribution/$CAMNAME
[ "$UPX" = "on" ] && zip -j $ddir/$CAMNAME.zip -xi $rdir/$CAM_F/Distribution/$CAMNAME-upx;
[ "$N_LIBUSB" = "-libusb" ] && zip -j $ddir/$CAMNAME.zip -xi $rdir/$CAM_F/Distribution/$SMARGONAME;
[ "$BUILD_LOG" = "on" ] && zip -j $ddir/$CAMNAME.zip -xi $rdir/$CAM_F/Distribution/build.log;
[ -e $rdir/$CAM_F/Distribution/build.log ] && rm -rf $rdir/$CAM_F/Distribution/build.log;
if [ "$ANDROID_APP" = "on" ] && [ -e $ddir/application/cam.apk ] ; then
cd $rdir
apkdir="storage/OSEbuild/installation";
if [ "$N_PCSC" = "-pcsc" ] && [ "$CCID_ANDROID" = "on" ] ; then
mkdir -p $apkdir
zip -j $apkdir/pcscd-${ABI}.zip -xi $PREFIX/sbin/pcscd
zip -j $apkdir/libccid-${ABI}.zip -xi $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so
zip -j $apkdir/libccidtwin-${ABI}.zip -xi $PREFIX/drivers/serial/libccidtwin.so
zip -j $apkdir/Info.plist.zip -xi $PREFIX/drivers/ifd-ccid.bundle/Contents/Info.plist
zip -r $ddir/$CAMNAME.zip -xi $apkdir;
rm -rf $rdir/storage;
fi
mkdir -p $apkdir
if [ "$UPX" = "on" ] ; then
cp $rdir/$CAM_F/Distribution/$CAMNAME-upx $apkdir/oscam
else
cp $rdir/$CAM_F/Distribution/$CAMNAME $apkdir/oscam
fi
zip -j $apkdir/oscam-${ABI}.zip -xi $apkdir/oscam
rm -rf $apkdir/oscam
zip -r $ddir/$CAMNAME.zip -xi $apkdir;
zip -j $ddir/$CAMNAME.zip -xi $ddir/application/cam.apk;
rm -rf $rdir/storage;
fi
[ "$selected" = "stapi" ] && plugin;
[ "$UPX" = "on" ] && rm -rf $rdir/$CAM_F/Distribution/$CAMNAME-upx;
}
####
plugin() {
plugin_su="plugin_su/oscam";
mkdir -p $rdir/$plugin_su
cd $rdir
wget -q -O $rdir/plugin_su/OSCam.png https://raw.githubusercontent.com/su-mak/app/master/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
cp $rdir/$CAM_F/Distribution/$CAMNAME $rdir/plugin_su/OSCam
if [ ! -e $rdir/plugin_su/OSCam.descr ] ; then
echo "# oscam-1.20-unstable_svn-${REV}${NP}" >> $rdir/plugin_su/OSCam.descr
echo "oscam-1.20-unstable_svn-${REV}${NP}" >> $rdir/plugin_su/OSCam.descr
echo "" >> $rdir/plugin_su/OSCam.descr
echo "[NEW_API_V1]" >> $rdir/plugin_su/OSCam.descr
echo "" >> $rdir/plugin_su/OSCam.descr
#echo "uninstall :" >> $rdir/plugin_su/OSCam.descr
#echo "/data/plugin/oscam*" >> $rdir/plugin_su/OSCam.descr
#echo "/data/plugin/OSCam*" >> $rdir/plugin_su/OSCam.descr
#echo "" >> $rdir/plugin_su/OSCam.descr
fi
if [ ! -e $rdir/$plugin_su/oscam.conf ] ; then
echo "" >> $rdir/$plugin_su/oscam.conf
echo "[global]" >> $rdir/$plugin_su/oscam.conf
echo "disablelog                    = 1" >> $rdir/$plugin_su/oscam.conf
echo "logfile                       = $CONF/oscam.log" >> $rdir/$plugin_su/oscam.conf
echo "clienttimeout                 = 8000" >> $rdir/$plugin_su/oscam.conf
echo "nice                          = -1" >> $rdir/$plugin_su/oscam.conf
echo "preferlocalcards              = 1" >> $rdir/$plugin_su/oscam.conf
echo "" >> $rdir/$plugin_su/oscam.conf
echo "[streamrelay]" >> $rdir/$plugin_su/oscam.conf
echo "stream_relay_enabled          = 0" >> $rdir/$plugin_su/oscam.conf
echo "" >> $rdir/$plugin_su/oscam.conf
echo "[dvbapi]" >> $rdir/$plugin_su/oscam.conf
echo "enabled                       = 1" >> $rdir/$plugin_su/oscam.conf
echo "au                            = 1" >> $rdir/$plugin_su/oscam.conf
echo "pmt_mode                      = 5" >> $rdir/$plugin_su/oscam.conf
echo "request_mode                  = 1" >> $rdir/$plugin_su/oscam.conf
echo "user                          = dvbapiau" >> $rdir/$plugin_su/oscam.conf
echo "write_sdt_prov                = 1" >> $rdir/$plugin_su/oscam.conf
echo "" >> $rdir/$plugin_su/oscam.conf
echo "[webif]" >> $rdir/$plugin_su/oscam.conf
echo "httpport                      = 8888" >> $rdir/$plugin_su/oscam.conf
echo "httpallowed                   = 127.0.0.1,192.168.0.1-192.168.255.255" >> $rdir/$plugin_su/oscam.conf
echo "" >> $rdir/$plugin_su/oscam.conf
fi
if [ ! -e $rdir/$plugin_su/oscam.user ] ; then
echo "" >> $rdir/$plugin_su/oscam.user
echo "[account]" >> $rdir/$plugin_su/oscam.user
echo "user                          = dvbapiau" >> $rdir/$plugin_su/oscam.user
echo "group                         = 1,2,3,4,5,6,7,8" >> $rdir/$plugin_su/oscam.user
echo "" >> $rdir/$plugin_su/oscam.user
fi
if [ ! -e $rdir/$plugin_su/oscam.server ] ; then
echo "" >> $rdir/$plugin_su/oscam.server
echo "[reader]" >> $rdir/$plugin_su/oscam.server
echo "label                         = smartcard" >> $rdir/$plugin_su/oscam.server
echo "enable                        = 0" >> $rdir/$plugin_su/oscam.server
echo "protocol                      = stapi" >> $rdir/$plugin_su/oscam.server
echo "device                        = 000:001" >> $rdir/$plugin_su/oscam.server
echo "group                         = 1" >> $rdir/$plugin_su/oscam.server
echo "" >> $rdir/$plugin_su/oscam.server
fi
if [ ! -e $rdir/$plugin_su/oscam.dvbapi ] ; then
echo "S: stapi1 pmt1_1.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_2.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_3.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_4.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_5.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_1.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_2.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_3.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_4.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_5.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_1.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_2.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_3.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_4.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_5.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_1.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_2.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_3.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_4.tmp" >> $rdir/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_5.tmp" >> $rdir/$plugin_su/oscam.dvbapi
fi
zip -r plugin_su.zip -xi plugin_su
zip -j $ddir/$CAMNAME.zip -xi plugin_su.zip;
rm -rf $rdir/plugin_su*
}
####
OSCAM_EMU() {
SVN_EMU="https://github.com/oscam-emu/oscam-emu/trunk"
SVN_SOURCE="http://www.streamboard.tv/svn/oscam/trunk"
REV_EMU=$(svn info $SVN_EMU | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="67";
CAM_F="OSCam_Emu";
NP="-emu";
[ -e $rdir/emu ] && FILE_REV=$(svn info $rdir/emu | grep Revision | cut -d ' ' -f 2);
rev
}
####
OSCAM_MODERN() {
SVN_SOURCE="http://www.streamboard.tv/svn/oscam-addons/modern"
REV_EMU=$(svn info $SVN_SOURCE | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="180";
CAM_F="OSCam_Modern";
NP="-modern";
[ -e $rdir/$CAM_F ] && FILE_REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2);
rev
}
####
OSCAM() {
SVN_SOURCE="http://www.streamboard.tv/svn/oscam/trunk"
REV_EMU=$(svn info $SVN_SOURCE | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="10";
CAM_F="OSCam";
NP="";
[ -e $rdir/$CAM_F ] && FILE_REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2);
rev
}
####
OSCAM_PATCHED() {
SVN_SOURCE="https://github.com/oscam-emu/oscam-patched/trunk"
REV_EMU=$(svn info $SVN_SOURCE | grep Revision | cut -d ' ' -f 2)
REV=$REV_EMU
SVN_MIN="10";
CAM_F="OSCam_patched";
NP="-patched";
[ -e $rdir/$CAM_F ] && FILE_REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2);
rev
}
####
rev() {
if [ ! -e $rdir/$CAM_F ] ; then
REV=$(dialog --no-cancel --title "Online SVN:$REV_EMU ($SVN_MIN to $REV_EMU)" --inputbox "$REV" 8 30 "$REV_EMU" 3>&1 1>&2 2>&3)
else
dialog --title "$CAM_F UPDATE" --backtitle "" --yesno "Online SVN ('$REV_EMU') = Local SVN ('$FILE_REV')" 7 60
response=$?
case $response in
   0) 
REV=$(dialog  --no-cancel --title "Local svn:$FILE_REV  ($SVN_MIN to $REV_EMU)" --inputbox "$REV" 8 30 "$REV_EMU" 3>&1 1>&2 2>&3)
;;
   1)   
   if [ "$PLUS_MENU" = "on" ] ; then
   menu_plus
   else
   menu_android
   fi
   ;;
   255) echo "[ESC] key pressed.";;
esac
fi
if [ "$REV" -ge $SVN_MIN ] && [ "$REV" -le "$REV_EMU" ] ; then
null="null"
else
rev
fi
if [ -e $rdir/$CAM_F ] ; then
rm -rf $rdir/$CAM_F
fi
if [ "$CAM_F" = "OSCam_Emu" ] ; then
cd $rdir
svn co -r $REV $SVN_EMU emu | $progressbox
if [ 225 -le "$REV" ] ; then
REV=$(grep -a " Makefile" emu/oscam-emu.patch | grep -a "revision" | cut -c24-28)
else
REV=$(grep -a " Makefile" emu/oscam-emu.patch | grep -a "revision" | cut -c24-27)
fi
cd $rdir
svn co -r $REV $SVN_SOURCE $CAM_F | $progressbox
else
cd $rdir
svn co -r $REV $SVN_SOURCE $CAM_F | $progressbox
REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2)
fi
FILE_REV=$(svn info $rdir/$CAM_F | grep Revision | cut -d ' ' -f 2)
cd $rdir/$CAM_F
[ "$CAM_F" = "OSCam_Emu" ] && patch -p0 < ../emu/oscam-emu.patch | $progressbox;
######
if [ "$PLUS_MENU" = "on" ] ; then
menu_plus
else
menu_android
fi
######
}
#################################################
ANDROID_NDK() {
if [ "$ANDROID_NDK_AU_DOWNLOAD" = "on" ] ; then
[ ${MACHINE_TYPE} != 'x86_64' ] && ANDROID_NDK_REV="r10e";
ANDROID_NDK_ROOT="$btdir/android-ndk-${ANDROID_NDK_REV}";
if [ ! -e $tcdir ] ; then
if [ ! -e ${ANDROID_NDK_ROOT} ] ; then
[ ! -e "$rdir/toolchains" ] && mkdir -p $rdir/toolchains;
[ ! -e $btdir ] && mkdir -p $btdir;
cd $btdir
if [ ${MACHINE_TYPE} = 'x86_64' ] ; then
wget -c --progress=bar:force "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip" 6 50
if [ ! -e $btdir/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip'' 7 60
clear && exit;
fi
unzip android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip | $progressbox
[ "$BACKUP" = "off" ]  && rm android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.zip;
else
wget -c --progress=bar:force "http://dl.google.com/android/ndk/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin" 6 50
if [ ! -e $btdir/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'http://dl.google.com/android/ndk/android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin'' 7 60
clear && exit;
fi
chmod a+x android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin
./android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin 2>&1 | $progressbox
[ "$BACKUP" = "off" ]  && rm android-ndk-${ANDROID_NDK_REV}-linux-${M_TYPE}.bin;
fi
fi
fi
else
if [ ! -e ${ANDROID_NDK_ROOT} ] ; then
ANDROID_NDK_ROOT=$(dialog --no-cancel --inputbox "ANDROID_NDK_ROOT?" 8 78 $ANDROID_NDK_ROOT 3>&1 1>&2 2>&3)
ANDROID_NDK
fi
if [ ! -e ${ANDROID_NDK_ROOT} ] ; then
ANDROID_NDK
fi
fi
if [ ! -e $tcdir ] ; then
$ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --arch=$ARCH --install-dir=$tcdir --platform=android-${ANDROID_API_LEVEL} --toolchain=${Toolchain}-${TOOLCHAIN_VERSION} 2>&1 | $progressbox 
cd $tcdir
##OSCam TommyDS patch
if [ ! -e stdint.h.patch ] && [ "$NDK_REV" -le "14" ] && [ "$ANDROID_API_LEVEL" -lt "21" ] ; then
echo '@@ -259,4 +259,10 @@' >> stdint.h.patch
echo ' /* Keep the kernel from trying to define these types... */' >> stdint.h.patch
echo ' #define __BIT_TYPES_DEFINED__' >> stdint.h.patch
echo '' >> stdint.h.patch
echo '+#if defined(__LP64__)' >> stdint.h.patch
echo '+#  define SIZE_MAX       UINT64_MAX' >> stdint.h.patch
echo '+#else' >> stdint.h.patch
echo '+#  define SIZE_MAX       UINT32_MAX' >> stdint.h.patch
echo '+#endif' >> stdint.h.patch
echo '+' >> stdint.h.patch
echo ' #endif /* _STDINT_H */' >> stdint.h.patch
patch -p1 < stdint.h.patch  sysroot/usr/include/stdint.h
fi
fi
if [ ! -e $tcdir ] ; then
dialog --title "ERROR!" --msgbox '                 ANDROID BUILD ERROR! \n \n ARCH='$ARCH' \n TOOLCHAIN_VERSION='$TOOLCHAIN_VERSION' \n ANDROID_API_LEVEL='$ANDROID_API_LEVEL'' 9 60
clear && exit;
fi
###############################
export PATH=$tcdir/bin:$PATH
#export SYSROOT=$tcdir/$Toolchain/sysroot
CROSS=$tcdir/bin/${PLATFORM}-
PREFIX=$tcdir/sysroot/usr
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
###############################
OPENSSL
[ "$LIBUSB_ANDROID" = "on" ]  && LIBUSB;
if [ "$ANDROID_APP" = "on" ] && [ "$LIBUSB_ANDROID" = "on" ] && [ "$PCSC_ANDROID" = "on" ] ; then
PCSCLITE
[ "$CCID_ANDROID" = "on" ]  && CCID;
fi
}
####
OSSL(){
echo "---------------------------------------------------------";
echo "BUILD openssl-${OPENSSL_VERSION}: (5-10 minutes)";
echo "---------------------------------------------------------";
sleep 5
}
OPENSSL(){
if [ ! -e $PKG_CONFIG_PATH/openssl.pc ] ; then
OSSL | $progressbox
cd $btdir
if [ ! -e $btdir/openssl-${OPENSSL_VERSION}.tar.gz ] ; then
wget -c --progress=bar:force "http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "openssl-${OPENSSL_VERSION}.tar.gz" 6 50
if [ ! -e $btdir/openssl-${OPENSSL_VERSION}.tar.gz ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz'' 7 60
clear && exit;
fi
fi
tar -xvf $btdir/openssl-${OPENSSL_VERSION}.tar.gz
cd $btdir/openssl-${OPENSSL_VERSION}
####
if [ ! -e 10-main.conf.patch ] && [ "$NDK_REV" -ge "18" ] ; then
echo '@@ -900,7 +900,7 @@' >> 10-main.conf.patch
echo '         # systems are perfectly capable of executing binaries targeting' >> 10-main.conf.patch
echo '         # Froyo. Keep in mind that in the nutshell Android builds are' >> 10-main.conf.patch
echo '         # about JNI, i.e. shared libraries, not applications.' >> 10-main.conf.patch
echo '-        cflags           => add(picker(default => "-mandroid -fPIC --sysroot=\$(CROSS_SYSROOT) -Wa,--noexecstack")),' >> 10-main.conf.patch
echo '+        cflags           => add(picker(default => "-fPIC --sysroot=\$(CROSS_SYSROOT) -Wa,--noexecstack")),' >> 10-main.conf.patch
echo '         bin_cflags       => "-pie",' >> 10-main.conf.patch
echo '     },' >> 10-main.conf.patch
echo '     "android-x86" => {' >> 10-main.conf.patch
echo '@@ -940,7 +940,7 @@' >> 10-main.conf.patch
echo ' ' >> 10-main.conf.patch
echo '     "android64" => {' >> 10-main.conf.patch
echo '         inherit_from     => [ "linux-generic64" ],' >> 10-main.conf.patch
echo '-        cflags           => add(picker(default => "-mandroid -fPIC --sysroot=\$(CROSS_SYSROOT) -Wa,--noexecstack")),' >> 10-main.conf.patch
echo '+        cflags           => add(picker(default => "-fPIC --sysroot=\$(CROSS_SYSROOT) -Wa,--noexecstack")),' >> 10-main.conf.patch
echo '         bin_cflags       => "-pie",' >> 10-main.conf.patch
echo '     },' >> 10-main.conf.patch
echo '     "android64-aarch64" => {' >> 10-main.conf.patch
patch -p1 < 10-main.conf.patch  Configurations/10-main.conf
fi
####
export CROSS_SYSROOT=$tcdir/sysroot
    case $ABI in
	armeabi)CONFIG="android-armeabi";;
	armeabi-v7a)CONFIG="android -march=armv7-a";;
	arm64-v8a)CONFIG="android64-aarch64";;
	x86)CONFIG="android-x86";;
	x86_64)CONFIG="android64";;
	mips)"android-mips";;
	mips64)CONFIG="android";;
    esac
CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib ./Configure ${CONFIG} --prefix=${CROSS_SYSROOT}/usr -D__ANDROID_API__=${ANDROID_API_LEVEL} no-afalgeng no-asan no-asm no-bf no-camellia no-cast no-crypto-mdebug no-crypto-mdebug-backtrace no-dgram no-dh no-dsa no-dtls no-dtls1 no-dtls1_2 no-ec no-ec_nistp_64_gcc_128 no-ecdh no-ecdsa no-egd no-engine no-fuzz-afl no-fuzz-libfuzzer no-gost no-heartbeats no-idea no-md2 no-md4 no-mdc2 no-msan no-rc2 no-rc4 no-rc5 no-rfc3779 no-sctp no-seed no-srp no-srtp no-ssl-trace no-ssl3 no-ssl3-method no-tls1 no-ubsan no-ui no-unit-test no-weak-ssl-ciphers no-whirlpool
make install
rm -rf $btdir/openssl-${OPENSSL_VERSION};
rm -rf $PREFIX/lib/libssl.so*
rm -rf $PREFIX/lib/libcrypto.so*
[ "$BACKUP" = "off" ]  && rm -rf $btdir/openssl-${OPENSSL_VERSION}.tar.gz;
if [ ! -e $PKG_CONFIG_PATH/openssl.pc ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: openssl-${OPENSSL_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
LUSB(){
echo "---------------------------------------------------------";
echo "BUILD libusb-${LIBUSB_VERSION}: (2-5 minutes)"
echo "---------------------------------------------------------";
sleep 5
}
LIBUSB(){
if [ ! -e $PKG_CONFIG_PATH/libusb-1.0.pc ] ; then
LUSB | $progressbox
cd $btdir
if [ ! -e $btdir/libusb-${LIBUSB_VERSION}.tar.bz2 ] ; then
wget -c --progress=bar:force "https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/libusb-${LIBUSB_VERSION}.tar.bz2" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "libusb-${LIBUSB_VERSION}.tar.bz2" 6 50
if [ ! -e $btdir/libusb-${LIBUSB_VERSION}.tar.bz2 ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://github.com/libusb/libusb/releases/download/v${LIBUSB_VERSION}/libusb-${LIBUSB_VERSION}.tar.bz2'' 7 60
clear && exit;
fi
fi
tar -jxf $btdir/libusb-${LIBUSB_VERSION}.tar.bz2
cd $btdir/libusb-${LIBUSB_VERSION}
./configure CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" --host=${PLATFORM} --prefix=${PREFIX} --enable-static --disable-shared --disable-udev
make
make install
rm -rf $btdir/libusb-${LIBUSB_VERSION};
[ "$BACKUP" = "off" ]  && rm -rf $btdir/libusb-${LIBUSB_VERSION}.tar.bz2;
if [ ! -e $PKG_CONFIG_PATH/libusb-1.0.pc ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: libusb-${LIBUSB_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
PCSCL(){
echo "---------------------------------------------------------";
echo "BUILD pcsc-lite-${PCSC_LITE_VERSION}: (2-5 minutes)"
echo "---------------------------------------------------------";
sleep 5
}
PCSCLITE(){
if [ ! -e $PKG_CONFIG_PATH/libpcsclite.pc ] ; then
PCSCL | $progressbox
cd $btdir
if [ ! -e $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2 ] ; then
wget -c --progress=bar:force "https://pcsclite.apdu.fr/files/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2" 6 50
if [ ! -e $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2 ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://pcsclite.apdu.fr/files/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2'' 7 60
clear && exit;
fi
fi
tar -jxf $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2
cd $btdir/pcsc-lite-${PCSC_LITE_VERSION}
##diff -Naur sd-daemon.c sd-daemon.c.patch
if [ ! -e sd-daemon.c.patch ] ; then
echo '@@ -32,7 +32,7 @@' >> sd-daemon.c.patch
echo ' #include <sys/stat.h>' >> sd-daemon.c.patch
echo ' #include <sys/socket.h>' >> sd-daemon.c.patch
echo ' #include <sys/un.h>' >> sd-daemon.c.patch
echo '-#include <sys/fcntl.h>' >> sd-daemon.c.patch
echo '+#include <fcntl.h>' >> sd-daemon.c.patch
echo ' #include <netinet/in.h>' >> sd-daemon.c.patch
echo ' #include <stdlib.h>' >> sd-daemon.c.patch
echo ' #include <errno.h>' >> sd-daemon.c.patch
echo '@@ -44,7 +44,7 @@' >> sd-daemon.c.patch
echo ' #include <limits.h>' >> sd-daemon.c.patch
echo ' ' >> sd-daemon.c.patch
echo ' #if defined(__linux__)' >> sd-daemon.c.patch
echo '-#include <mqueue.h>' >> sd-daemon.c.patch
echo '+//#include <mqueue.h>' >> sd-daemon.c.patch
echo ' #endif' >> sd-daemon.c.patch
echo ' ' >> sd-daemon.c.patch
echo ' #include "sd-daemon.h"' >> sd-daemon.c.patch
echo '@@ -377,7 +377,7 @@' >> sd-daemon.c.patch
echo ' ' >> sd-daemon.c.patch
echo '         return 1;' >> sd-daemon.c.patch
echo ' }' >> sd-daemon.c.patch
echo '-' >> sd-daemon.c.patch
echo '+/*' >> sd-daemon.c.patch
echo ' _sd_export_ int sd_is_mq(int fd, const char *path) {' >> sd-daemon.c.patch
echo ' #if !defined(__linux__)' >> sd-daemon.c.patch
echo '         return 0;' >> sd-daemon.c.patch
echo '@@ -414,7 +414,7 @@' >> sd-daemon.c.patch
echo '         return 1;' >> sd-daemon.c.patch
echo ' #endif' >> sd-daemon.c.patch
echo ' }' >> sd-daemon.c.patch
echo '-' >> sd-daemon.c.patch
echo '+*/' >> sd-daemon.c.patch
echo ' _sd_export_ int sd_notify(int unset_environment, const char *state) {' >> sd-daemon.c.patch
echo ' #if defined(DISABLE_SYSTEMD) || !defined(__linux__) || !defined(SOCK_CLOEXEC)' >> sd-daemon.c.patch
echo '         return 0;' >> sd-daemon.c.patch
patch -p1 < sd-daemon.c.patch  src/sd-daemon.c
fi
./configure CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" LIBUSB_LIBS="${tcdir}/sysroot/usr/lib/libusb-1.0.a" LIBUSB_CFLAGS="-I${tcdir}/sysroot/usr/include/libusb-1.0" --disable-libudev --host=${PLATFORM} --prefix=${PREFIX} --exec-prefix=${PREFIX} --enable-static --enable-serial --enable-static --disable-shared --enable-usb --enable-libusb --enable-usbdropdir="$PCSC_APP_DIR/drivers" --enable-ipcdir="/dev" --enable-confdir="$PCSC_APP_DIR/reader.conf.d"
make
make install
[ "$UPX" = "on" ] && UPX_ && $btdir/upx-${UPX_VERSION}-${UPX_TYPE}_linux/upx --brute $PREFIX/sbin/pcscd;
rm -rf $btdir/pcsc-lite-${PCSC_LITE_VERSION};
[ "$BACKUP" = "off" ]  && rm -rf $btdir/pcsc-lite-${PCSC_LITE_VERSION}.tar.bz2;
if [ ! -e $PKG_CONFIG_PATH/libpcsclite.pc ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: pcsc-lite-${PCSC_LITE_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
CCI(){
echo "---------------------------------------------------------";
echo "BUILD ccid-${CCID_VERSION}: (2-5 minutes)"
echo "---------------------------------------------------------";
sleep 5
}
CCID(){
if [ ! -e $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so ] ; then
CCI | $progressbox
cd $btdir
if [ ! -e $btdir/ccid-${CCID_VERSION}.tar.bz2 ] ; then
wget -c --progress=bar:force "https://ccid.apdu.fr/files/ccid-${CCID_VERSION}.tar.bz2" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "ccid-${CCID_VERSION}.tar.bz2" 6 50
if [ ! -e $btdir/ccid-${CCID_VERSION}.tar.bz2 ] ; then
dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://ccid.apdu.fr/files/ccid-${CCID_VERSION}.tar.bz2'' 7 60
clear && exit;
fi
fi
tar -jxf $btdir/ccid-${CCID_VERSION}.tar.bz2
cd $btdir/ccid-${CCID_VERSION}
./configure CC=${CROSS}gcc LD=${CROSS}ld AR=${CROSS}ar STRIP=${CROSS}strip RANLIB=${CROSS}ranlib CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" LIBUSB_LIBS="${tcdir}/sysroot/usr/lib/libusb-1.0.a" LIBUSB_CFLAGS="-I${tcdir}/sysroot/usr/include/libusb-1.0" PCSC_LIBS="${tcdir}/sysroot/usr/lib/libpcsclite.a" PCSC_CFLAGS="-I${tcdir}/sysroot/usr/include/PCSC" --host=${PLATFORM} --prefix=${PREFIX} --exec-prefix=${PREFIX} --enable-twinserial --enable-serialconfdir="$PCSC_APP_DIR/reader.conf.d" --enable-static --enable-shared
make
make install
cd $rdir
[ ! -e $PREFIX/reader.conf.d ] && mkdir -p $PREFIX/reader.conf.d;
[ ! -e $PREFIX/drivers/serial ] && mkdir -p $PREFIX/drivers/serial;
[ ! -e $PREFIX/etc/udev/rules.d ] && mkdir -p $PREFIX/etc/udev/rules.d;
[ ! -e $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux ] && mkdir -p $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux
cp $btdir/ccid-${CCID_VERSION}/src/92_pcscd_ccid.rules $PREFIX/etc/udev/rules.d/92_pcscd_ccid.rules
cp $btdir/ccid-${CCID_VERSION}/src/Info.plist $PREFIX/drivers/ifd-ccid.bundle/Contents/Info.plist
cp $btdir/ccid-${CCID_VERSION}/src/.libs/libccid.so $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so
cp $btdir/ccid-${CCID_VERSION}/src/.libs/libccidtwin.so $PREFIX/drivers/serial/libccidtwin.so
if [ ! -e $PREFIX/reader.conf.d/libccidtwin ] ; then
cp $btdir/ccid-${CCID_VERSION}/src/reader.conf.in $PREFIX/reader.conf.d/libccidtwin
echo "#LIBPATH          $PCSC_APP_DIR/drivers/serial/libccidtwin.so" >> $PREFIX/reader.conf.d/libccidtwin
fi
rm -rf $btdir/ccid-${CCID_VERSION};
[ "$BACKUP" = "off" ]  && rm -rf $btdir/ccid-${CCID_VERSION}.tar.bz2;
if [ ! -e $PREFIX/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so ] ; then
dialog --title "EXIT" --yesno "BUILD ERROR: ccid-${CCID_VERSION}" 5 60
case $? in
   0) clear && exit ;;
esac
fi
fi
}
UPX_(){
if [ ! -e $btdir/upx-${UPX_VERSION}-${UPX_TYPE}_linux ] && [ "$UPX" = "on" ] ; then
cd $btdir
if [ ${MACHINE_TYPE} = 'x86_64' ] ; then
UPX_TYPE="amd64"
else
UPX_TYPE="i386"
fi
if [ ! -e $btdir/upx-${UPX_VERSION}-${UPX_TYPE}_linux.tar.xz ] ; then
wget -c --progress=bar:force "https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${UPX_TYPE}_linux.tar.xz" 2>&1 | while read -d "%" X; do sed 's:^.*[^0-9]\([0-9]*\)$:\1:' <<< "$X"; done | dialog --title "" --clear --stdout --gauge "upx-${UPX_VERSION}-${UPX_TYPE}_linux.tar.xz" 6 50
[ ! -e $btdir/upx-${UPX_VERSION}-${UPX_TYPE}_linux.tar.xz ] && dialog --title "ERROR!" --msgbox '                 DOWNLOAD ERROR! \n 'https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${UPX_TYPE}_linux.tar.xz'' 7 60 && clear && exit;
fi
tar -xf $btdir/upx-${UPX_VERSION}-${UPX_TYPE}_linux.tar.xz
fi
clear;
}
#################################
menu(){
selected=$(dialog --stdout --clear --colors --backtitle $0 --title "" --menu "" 9 60 8 \
	1	"Oscam" \
	2	"Oscam-emu" \
	3	"Oscam-modern" \
	4	"Oscam-patched");
case $selected in
	1) OSCAM ;;
	2) OSCAM_EMU ;;
	3) OSCAM_MODERN ;;
	4) OSCAM_PATCHED ;;
	esac
clear && exit;
}
####
menu_plus(){
if [ "$NDK_REV" -ge "17" ] ; then
Oreo="26	"'8.0_Oreo'" " ;
Pie="28	"'9.0_Pie'" " ;
fi
[ -e $ddir/patches/stapi/libwi.a ] && [ -e $ddir/patches/stapi/stapi.patch ] && stapi="stapi	"'Openbox_Xcruiser(experimental)'" " ;
selected=$(dialog --stdout --clear --colors --backtitle $0 --title "" --menu "" 16 60 10 \
	A3	"Amiko A3" \
	A4	"Amiko A4" \
	A5	"Amiko A5" \
	v2.x	"WeTek Play 2 WeOS v2.x" \
	v3.x	"WeTek Play 2 WeOS v3.x" \
	9	"2.3–2.3.2 Gingerbread" \
	12	"3.1 Honeycomb" \
	13	"3.2 Honeycomb" \
	14	"4.0 Ice Cream_Sandwich" \
	15	"4.0.3–4.0.4 Ice Cream Sandwich" \
	16	"4.1 Jelly Bean" \
	17	"4.2 Jelly Bean" \
	18	"4.3 Jelly Bean" \
	19	"4.4 KitKat" \
	21	"5.0 Lollipop" \
	22	"5.1 Lollipop" \
	23	"6.0 Marshmallow" \
	24	"7.0 Nougat" \
	$Oreo \
	$Pie \
	$stapi);
case $selected in
	A3)
	BOX="Amiko_A3"
	ANDROID_API_LEVEL="19"
	ANDROID_APP="off"
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	CONF="/var/tuxbox/config"
	android
	;;
	A4)
	BOX="Amiko_A4"
	ANDROID_API_LEVEL="22"
	ANDROID_APP="off"
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	CONF="/var/tuxbox/config"
	android
	;;
	A5)
	BOX="Amiko_A5"
	ANDROID_API_LEVEL="24"
	ANDROID_APP="off"
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	CONF="/var/tuxbox/config"
	android
	;;
	v2.x)
	BOX="WeTek_Play_2_WeOS_v2.x"
	ANDROID_API_LEVEL="21"
	ANDROID_APP="on"
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	android
	;;
	v3.x)
	BOX="WeTek_Play_2_WeOS_v3.x"
	ANDROID_API_LEVEL="23"
	ANDROID_APP="on"
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	android
	;;
	stapi)
	BOX="Openbox_Xcruiser"
	ANDROID_API_LEVEL="21"
	ANDROID_APP="off"
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	EXTRA_LIBS="-L$ddir/patches/stapi -lwi"
	ABI="armeabi-v7a";
	CONF="/data/plugin/oscam"
	android
	rm -rf $rdir/$CAM_F
	;;
	9|12|13|14|15|16|17|18|19|21|22|23|24|26|27|28)
	ANDROID_API_LEVEL=$selected
	menu_android
	;;
	*)menu_android;;
	esac
clear && exit;
}
####
menu_android(){
cmd=(dialog --separate-output --no-cancel --checklist "$CAM_F-Rev:$FILE_REV" 16 60 10)
options=(armeabi "armv5" off
	 armeabi-v7a "armv7-a" off
	 armeabi-v7a_neon "armv7-a_neon" off
	 x86 "i686-linux-android" off
	 mips "mipsel-linux-android" off
	 arm64 "aarch64-linux-android" off
	 x86_64 "x86_64-linux-android" off
	 mips64 "mips64el-linux-android" off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
for choice in $choices
do
    case $choice in
	armeabi)
	ARCH="arm";
	CFLAGS="-Os -march=armv5te -mtune=xscale -msoft-float"
	LDFLAGS="-Wl,--exclude-libs,libunwind.a "
	ABI="armeabi";
	android
	;;
	armeabi-v7a)
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	android
	;;
	armeabi-v7a_neon)
	ARCH="arm";
	CFLAGS="-Os -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mfpu=neon"
	LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
	ABI="armeabi-v7a";
	android
	;;
	x86)
	ARCH="x86";
	CFLAGS="-O2"
	LDFLAGS=""
	ABI="x86";
	android
	;;
	mips)
	ARCH="mips";
	CFLAGS="-O2 -mips32"
	LDFLAGS=""
	ABI="mips";
	android
	;;
	arm64)
	ARCH="arm64";
	CFLAGS="-O2"
	LDFLAGS=""
	[ "$ANDROID_API_LEVEL" -lt "21" ] && ANDROID_API_LEVEL="21"
	ABI="arm64-v8a";
	android
	;;
	x86_64)
	ARCH="x86_64";
	CFLAGS="-O2"
	LDFLAGS=""
	[ "$ANDROID_API_LEVEL" -lt "21" ] && ANDROID_API_LEVEL="21"
	ABI="x86_64";
	android
	;;
	mips64)
	ARCH="mips64";
	CFLAGS="-O2"
	LDFLAGS=""
	[ "$ANDROID_API_LEVEL" -lt "21" ] && ANDROID_API_LEVEL="21"
	ABI="mips64";
	android
	;;
	esac
	done
clear && exit;
}
#######################
export NCURSES_NO_UTF8_ACS=1;
#export LOCALE=UTF-8
#######################
case $1 in
h|-h|--h|help|-help|--help|Help|HELP)
MACHINE=`uname -o`
case "$MACHINE" in
GNU/Linux*)
echo "-----------------------------"
echo "Build:     "
echo "	Oscam";
echo "	Oscam-emu"
echo "	Oscam-modern";
echo "-----------------------------"
echo "PLATFORM:";
echo "	ANDROID:arm,x86,mips,arm64,x86_64,mips64";
echo "-----------------------------"
echo "Packages required:"
echo "		dialog subversion gcc make zip python pkg-config"
echo "-----------------------------"
echo "   $0"
echo "-----------------------------"
;;
*)
echo "this is not linux operating system";
;;
esac
exit 0;
;;
esac
#######################
menu
#######################
exit 0;
