#!/system/bin/sh

stop ril-daemon
#kill -9 `pidof rild`

/etc/scripts/send-coord.sh
/etc/scripts/gps-time.sh
/etc/scripts/stop-park.sh
/etc/scripts/obd.sh &