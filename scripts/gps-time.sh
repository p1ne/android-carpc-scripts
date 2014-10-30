#! /system/bin/sh

gpsSource=/dev/ttyUSB0

numSat=0

while [ $numSat -lt 4 ] ; do
   sleep 5
   gpsString=`grep -m1 GPGGA $gpsSource`
   numSat=`echo $gpsString | cut -f8 -d,`
done

date -s "$(grep -m1 -e 'G[PN]RMC' $gpsSource | cut -f 2,10 -d, | sed -e 's/\(....\)\(..\),\(..\)\(..\)\(..\)/\5\4\3\1.\2/')"

# Reset GPS receiver
#echo '$PSRF101,0,0,0,000,0,0,12,8*1C' > /dev/ttyUSB0