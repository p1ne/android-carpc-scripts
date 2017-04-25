#!/system/bin/sh

dumpsys location | grep mHasStatus > /dev/null
if [ $? -eq 1 ] ; then
   if [ ! -f /dev/ttyUSB0 ] ; then
       for i in $(seq 15) ; do
           if [ -e /dev/ttyUSB0] ; then
               chmod 644 /dev/ttyUSB0
               stty -F /dev/ttyUSB0 ispeed 4800
               setprop "ro.kernel.android.gps" "/dev/ttyUSB0"
               setprop "ro.kernel.android.gps.speed" "4800"
           fi
       sleep 1
       done
   fi
   am startservice -a "org.broeuschmeul.android.gps.usb.provider.nmea.intent.action.START_GPS_PROVIDER"
fi

