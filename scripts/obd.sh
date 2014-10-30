#!/system/bin/sh

function calculate()
{
pidValue=$1
params=$2
offset=$3
divider=$4


if [ $params == "A" ] ; then
  valA=$(printf "%d" 0x$(echo $1 | cut -f3 -d\ ))
  valB=0
  echo $(expr $valA - $offset)
fi
if [ $params == "AB" ] ; then
  valA=$(printf "%d" 0x$(echo $1 | cut -f3 -d\ ))
  valB=$(printf "%d" 0x$(echo $1 | cut -f4 -d\ ))
  valRes=`expr $valA \* 256`
  valRes=`expr $valRes + $valB`
  if [ $divider -eq 100 -o $divider -eq 1000 ] ; then
    echo `expr $valRes / $divider`.`expr $valRes % $divider `
  else
    echo `expr $valRes / $divider`
  fi
fi

}

function temperature()
{
  calculate "$1" A 40
}

function valueA()
{
  calculate "$1" A 0
}

function rpm()
{
  calculate "$1" AB 0 4
}

function volts()
{
  calculate "$1" AB 0 1000
}

function runtime()
{
  calculate "$1" AB 0 1
}

### 03 - read codes, 3 codes per frame, returns n*6 bytes
### A7-A6: 00 - P, 01 -C, 10 -B, 11 - U
### A5-A4: 2nd DTC char
### A3-A0: 3rd DTC char
### B7-B4: 3th DTC char
### B3-B0: 4th DTC char
### 04 - clear codes

wt=250000

stty -F /dev/ttyUSB1 38400 onlret
echo "atz\r" > /dev/ttyUSB1
sleep 1
echo "atl1\r" > /dev/ttyUSB1
sleep 1

while [ 1 ] ; do
pid01=$(usleep $wt; echo "01 01\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 4. no of codes, A7 - lamp, A0-A6 - number or codes
pid05=$(usleep $wt; echo "01 05\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 1. engine coolant A-40
pid0c=$(usleep $wt; echo "01 0C\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 2. RPM ((A*256)+B)/4
pid0d=$(usleep $wt; echo "01 0D\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 1. speed. A
pid1f=$(usleep $wt; echo "01 1F\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 2. run time (A*256)+B
pid42=$(usleep $wt; echo "01 42\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 2. PCM volts. ((A*256)+B)/1000
pid46=$(usleep $wt; echo "01 46\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 1. ambient air A-40
#pid5c=$(usleep $wt; echo "01 5C\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 1. engine oil A-40
#pid5e=$(usleep $wt; echo "01 5E\r" > /dev/ttyUSB1 && head -n 1 /dev/ttyUSB1 && echo "\r" > /dev/ttyUSB1) # 2. fuel rate ((A*256)+B)*0.05

echo -n > /mnt/sdcard/obd/obd.txt
date >> /mnt/sdcard/obd/obd.txt
(echo -n "Errors " ; valueA "$pid01") >> /mnt/sdcard/obd/obd.txt
(echo -n "RPM " ; rpm "$pid0c") >> /mnt/sdcard/obd/obd.txt
(echo -n "Speed " ; valueA "$pid0d") >> /mnt/sdcard/obd/obd.txt
(echo -n "Engine C " ; temperature "$pid05") >> /mnt/sdcard/obd/obd.txt
(echo -n "Ambient C " ; temperature "$pid46") >> /mnt/sdcard/obd/obd.txt
(echo -n "Volts " ; volts "$pid42") >> /mnt/sdcard/obd/obd.txt
(echo -n "Runtime " ; runtime "$pid1f") >> /mnt/sdcard/obd/obd.txt
echo "" >> /mnt/sdcard/obd/obd.txt

sleep 10

done
