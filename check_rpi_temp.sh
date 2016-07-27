#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

if [ $# -ne 2 ]; then
        echo "Wrong usage! Have to be: $0 temp_warning temp_critical"
        exit $EXIT_UNKNOW
fi

temp_warning=$1
temp_critical=$2

temp=`cat /sys/class/thermal/thermal_zone0/temp`
temp=`echo $temp/1000 | bc`

temp_text="- CPU Temp: $temp\c\|temp=$temp($temp_warning|$temp_critical)"

if [ $temp -lt $temp_warning ]; then
        echo "OK $temp_text"
        exit $EXIT_OK
fi

if [ $temp -lt $temp_critical ]; then
        echo "WARNING $temp_text"
        exit $EXIT_WARNING
fi

echo "CRITICAL $temp_text"
exit $EXIT_CRITICAL
