#! /system/bin/sh

# Set your own www.notifymyandroid.com apikey in pre-last line of script

gpsSource=/dev/ttyUSB0

numSat=0

while [ $numSat -lt 4 ] ; do
   sleep 5
   gpsString=`grep -m1 GPGGA $gpsSource`
   numSat=`echo $gpsString | cut -f8 -d,`
done

lat=`echo $gpsString | cut -f3 -d,`
lon=`echo $gpsString | cut -f5 -d,`

decLat1=${lat:0:2}
decLon1=${lon:0:3}

decLat2=`echo ${lat:2} | tr -d .`
decLon2=`echo ${lon:3} | tr -d .`

decLat3=`expr $decLat2 / 6`
decLon3=`expr $decLon2 / 6`

decLat4=`expr ${decLat1}00000 + $decLat3`
decLon4=`expr ${decLon1}00000 + $decLon3`

if [ ${decLon1:0:1} -eq 0 ] ; then
  decLon4=0$decLon4
fi

decLat=`echo $decLat4 | cut -c1,2`.`echo $decLat4 | cut -c3-`
decLon=`echo $decLon4 | cut -c1,2,3`.`echo $decLon4 | cut -c4-`

#url="http://maps.yandex.ru/?ll=$decLon%2C$decLat%26z=14"
url="http://static-maps.yandex.ru/1.x/?l=map&pt=$decLon%2C$decLat%26z=16"

while ! ping -c1 www.notifymyandroid.com &>/dev/null; do :; done

cat | nc www.notifymyandroid.com 80 << EOF
POST /publicapi/notify/ HTTP/1.1
User-Agent: curl/7.26.0
Host: www.notifymyandroid.com
Accept: */*
Content-Length: 195
Content-Type: application/x-www-form-urlencoded

apikey=<key>&application=DasAuto&event=Coordinates&description=Coordinates&url=$url

EOF

