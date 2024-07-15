#!/bin/bash

# Originally from https://github.com/rockowitz/ddcutil/issues/63
# from @Ryanf55

Help()
{
   # Display Help
   echo "This script sets the brightness of all connected monitors"
   echo
   echo "Syntax: monitor_brightness [-h] brightness"
   echo "where:"
   echo "brightness     The brightness value to set (0-100) OR"
   echo "               up, down"
   echo "options:"
   echo "h     Print this Help."
   echo
}


while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

brightness=$1
brightness_c="0x10"

if [ -z "$brightness" ]
then 
    echo "Error. No brightness specified"
    exit 1
fi

GetBrightness()
{
   brightness=`ddcutil getvcp 10 | grep current | sed -e 's/.*current value = //'`
   # current value = value, max value = max
   # split before comma
   brightness=`echo $brightness | cut -d',' -f1`
}

# Check if brightness is "up" or "down"
if [ "$brightness" == "up" ]
then
   GetBrightness
   brightness=$((brightness + 10))
   echo "increasing brightness to $brightness"
elif [ "$brightness" == "down" ]
then
   GetBrightness
   brightness=$((brightness - 10))
   echo "decreasing brightness to $brightness"
fi

# Detect all monitor serial numbers
monitor_serials=`ddcutil detect --terse | grep Monitor: | sed -e 's/.*:.*:.*://'`

for serial_num in $monitor_serials;do 
    ddcutil --sn $serial_num setvcp ${brightness_c} ${brightness}
done
