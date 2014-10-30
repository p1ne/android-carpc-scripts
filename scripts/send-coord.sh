#! /system/bin/sh

# Set your own qpush.me user data in pre-last line of script in "name" and "code" fields

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

url="http://maps.yandex.ru/?ll=$decLon%2C$decLat%26z=14"

while ! ping -c1 qpush.me &>/dev/null; do :; done

cat | nc qpush.me 80 << EOF
POST /pusher/push_site/ HTTP/1.1
User-Agent: curl/7.26.0
Host: qpush.me
Accept: */*
Content-Length: 110
Content-Type: application/x-www-form-urlencoded

name=<yourname>&code=<yourcode>&sig=&cache=false&msg[text]=$url
EOF

