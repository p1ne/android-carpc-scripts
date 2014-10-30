#!/system/bin/sh

# set your phone number (format 7xxxxxxxxxx), username and password for Moscow parking zone. @ in username is to be changed to %40
# curl required
 
gpsSource=/dev/ttyUSB0
parkingPhone=<yourphone>
username=<yourname>
password=<yourpassword>

test ! -c $gpsSource && exit

numSat=0

while [ $numSat -lt 4 ] ; do
    sleep 5
    gpsString=`cat $gpsSource | grep -m1 GPGGA`
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

decLat=`echo $decLat4 | cut -c1,2`.`echo $decLat4 | cut -c3-`
decLon=`echo $decLon4 | cut -c1,2`.`echo $decLon4 | cut -c3-`

coord=$decLat,$decLon

while ! ping -c1 parkingmap.mos.ru &>/dev/null; do :; done

distance=$(curl -s -d "partnerID=Moscow" -d "layers=151600,001" -d "operation=zone_geodata" -d "name=**" -d "userLocation=$coord" -d "resultLimit=0-1" -d "center=1" -d "format=Xml" -d "pretty=1" http://parkingmap.mos.ru/AppHTTP.php | grep distance | cut -f2 -d: | tr -d \ ,)

test $distance -gt 1000 && exit 

test -f cook.txt && rm cook.txt

curl 'https://parkingcab.mos.ru/local/MPGU.php' \
	-s -c /tmp/cook.txt \
	-H 'Origin: http://parkingcab.mos.ru' \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-H 'Referer: http://parkingcab.mos.ru/'  \
	-H 'Connection: keep-alive'  \
	--data 'module=&login=%D0%92%D0%BE%D0%B9%D1%82%D0%B8+%D0%B2+%D0%BB%D0%B8%D1%87%D0%BD%D1%8B%D0%B9+%D0%BA%D0%B0%D0%B1%D0%B8%D0%BD%D0%B5%D1%82&_reqNo=0'  \
	--compressed > /dev/null

curl 'https://pgu.mos.ru/ru/auth/?return=https%3A%2F%2Fparkingcab.mos.ru%2Flocal%2FMPGU.php%2F%3Flogin%3D1%26redirect%3D'  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: http://parkingcab.mos.ru/' \
	-H 'Connection: keep-alive'  \
	--compressed > /dev/null

curl 'https://login.mos.ru/eaidit/eaiditweb/redirect.do?redirectto=https%3A%2F%2Fpgu.mos.ru%2Fru%2Fid%2F%3Fto%3Dhttps%253A%252F%252Fparkingcab.mos.ru%252Flocal%252FMPGU.php%252F%253Flogin%253D1%2526redirect%253D' \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: http://parkingcab.mos.ru/' \
	-H 'Connection: keep-alive' \
	--compressed > /dev/null

curl 'https://login.mos.ru/eaidit/eaiditweb/openouterlogin.do'  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: https://login.mos.ru/eaidit/eaiditweb/redirect.do?redirectto=https%3A%2F%2Fpgu.mos.ru%2Fru%2Fid%2F%3Fto%3Dhttps%253A%252F%252Fparkingcab.mos.ru%252Flocal%252FMPGU.php%252F%253Flogin%253D1%2526redirect%253D'  \
	-H 'Connection: keep-alive'  \
	--compressed > /dev/null

curl 'https://login.mos.ru/eaidit/eaiditweb/outerlogin.do'  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Origin: https://login.mos.ru'  \
	-H 'Content-Type: application/x-www-form-urlencoded'  \
	-H 'Referer: https://login.mos.ru/eaidit/eaiditweb/openouterlogin.do'  \
	-H 'Connection: keep-alive'  \
	--data "username=${username}&password=${password}"  \
	--compressed > /dev/null

curl 'https://login.mos.ru/eaidit/eaiditweb/loginok.do'  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: https://login.mos.ru/eaidit/eaiditweb/openouterlogin.do'  \
	-H 'Connection: keep-alive'  \
	--compressed > /dev/null

curl 'https://login.mos.ru/eaidit/eaiditweb/redirect.do?redirectto=https%3A%2F%2Fpgu.mos.ru%2Fru%2Fid%2F%3Fto%3Dhttps%253A%252F%252Fparkingcab.mos.ru%252Flocal%252FMPGU.php%252F%253Flogin%253D1%2526redirect%253D'  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: https://login.mos.ru/eaidit/eaiditweb/openouterlogin.do'  \
	-H 'Connection: keep-alive'  \
	--compressed > /dev/null

curl 'https://pgu.mos.ru/ru/id/?to=https%3A%2F%2Fparkingcab.mos.ru%2Flocal%2FMPGU.php%2F%3Flogin%3D1%26redirect%3D'  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: https://login.mos.ru/eaidit/eaiditweb/openouterlogin.do'  \
	-H 'Connection: keep-alive'  \
	--compressed > /dev/null

curl 'https://parkingcab.mos.ru/local/MPGU.php/?login=1&redirect='  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: https://login.mos.ru/eaidit/eaiditweb/openouterlogin.do'  \
	--compressed > /dev/null

curl 'https://parkingcab.mos.ru/'  \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Referer: https://login.mos.ru/eaidit/eaiditweb/openouterlogin.do'  \
	-H 'Connection: keep-alive'  \
	--compressed > /dev/null

curl 'https://parkingcab.mos.ru/' \
	-s -b cook.txt -c /tmp/cook.txt \
	-H 'Origin: https://parkingcab.mos.ru' \
	-H 'Referer: https://parkingcab.mos.ru/' \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-H 'Connection: keep-alive' \
	--data "module=Parking&operation=stopParking&parkingPhone=${parkingPhone}&extendDuration=60&page=frontpage" \
	--compressed > /dev/null

test -f cook.txt && rm cook.txt

