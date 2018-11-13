#! /bin/bash
####
plugin_su="plugin_su/oscam";
mkdir -p $sources/$plugin_su
wget -q -O $sources/plugin_su/OSCam.png https://raw.githubusercontent.com/su-mak/app/master/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
cp $sources/libs/$ABI/oscam $sources/plugin_su/OSCam
if [ ! -e $sources/plugin_su/OSCam.descr ] ; then
echo "# $name" >> $sources/plugin_su/OSCam.descr
echo "$name" >> $sources/plugin_su/OSCam.descr
echo "" >> $sources/plugin_su/OSCam.descr
echo "[NEW_API_V1]" >> $sources/plugin_su/OSCam.descr
echo "" >> $sources/plugin_su/OSCam.descr
#echo "uninstall :" >> $sources/plugin_su/OSCam.descr
#echo "/data/plugin/oscam*" >> $sources/plugin_su/OSCam.descr
#echo "/data/plugin/OSCam*" >> $sources/plugin_su/OSCam.descr
#echo "" >> $sources/plugin_su/OSCam.descr
fi
if [ ! -e $sources/$plugin_su/oscam.conf ] ; then
echo "" >> $sources/$plugin_su/oscam.conf
echo "[global]" >> $sources/$plugin_su/oscam.conf
echo "disablelog                    = 1" >> $sources/$plugin_su/oscam.conf
echo "logfile                       = $CONF/oscam.log" >> $sources/$plugin_su/oscam.conf
echo "clienttimeout                 = 8000" >> $sources/$plugin_su/oscam.conf
echo "nice                          = -1" >> $sources/$plugin_su/oscam.conf
echo "preferlocalcards              = 1" >> $sources/$plugin_su/oscam.conf
echo "" >> $sources/$plugin_su/oscam.conf
echo "[streamrelay]" >> $sources/$plugin_su/oscam.conf
echo "stream_relay_enabled          = 0" >> $sources/$plugin_su/oscam.conf
echo "" >> $sources/$plugin_su/oscam.conf
echo "[dvbapi]" >> $sources/$plugin_su/oscam.conf
echo "enabled                       = 1" >> $sources/$plugin_su/oscam.conf
echo "au                            = 1" >> $sources/$plugin_su/oscam.conf
echo "pmt_mode                      = 5" >> $sources/$plugin_su/oscam.conf
echo "request_mode                  = 1" >> $sources/$plugin_su/oscam.conf
echo "user                          = dvbapiau" >> $sources/$plugin_su/oscam.conf
echo "write_sdt_prov                = 1" >> $sources/$plugin_su/oscam.conf
echo "" >> $sources/$plugin_su/oscam.conf
echo "[webif]" >> $sources/$plugin_su/oscam.conf
echo "httpport                      = 8888" >> $sources/$plugin_su/oscam.conf
echo "httpallowed                   = 127.0.0.1,192.168.0.1-192.168.255.255" >> $sources/$plugin_su/oscam.conf
echo "" >> $sources/$plugin_su/oscam.conf
fi
if [ ! -e $sources/$plugin_su/oscam.user ] ; then
echo "" >> $sources/$plugin_su/oscam.user
echo "[account]" >> $sources/$plugin_su/oscam.user
echo "user                          = dvbapiau" >> $sources/$plugin_su/oscam.user
echo "group                         = 1,2,3,4,5,6,7,8" >> $sources/$plugin_su/oscam.user
echo "" >> $sources/$plugin_su/oscam.user
fi
if [ ! -e $sources/$plugin_su/oscam.server ] ; then
echo "" >> $sources/$plugin_su/oscam.server
echo "[reader]" >> $sources/$plugin_su/oscam.server
echo "label                         = smartcard" >> $sources/$plugin_su/oscam.server
echo "enable                        = 0" >> $sources/$plugin_su/oscam.server
echo "protocol                      = stapi" >> $sources/$plugin_su/oscam.server
echo "device                        = 000:001" >> $sources/$plugin_su/oscam.server
echo "group                         = 1" >> $sources/$plugin_su/oscam.server
echo "" >> $sources/$plugin_su/oscam.server
fi
if [ ! -e $sources/$plugin_su/oscam.dvbapi ] ; then
echo "S: stapi1 pmt1_1.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_2.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_3.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_4.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt1_5.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_1.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_2.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_3.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_4.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt2_5.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_1.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_2.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_3.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_4.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt3_5.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_1.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_2.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_3.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_4.tmp" >> $sources/$plugin_su/oscam.dvbapi
echo "S: stapi1 pmt4_5.tmp" >> $sources/$plugin_su/oscam.dvbapi
fi
zip -r plugin_su.zip -xi plugin_su
zip -j $dir/$name-$ABI.zip -xi plugin_su.zip;
rm -rf $sources/plugin_su*

