#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

if [ $# -ne 1 ]; then
	echo "UNKNOW: Wrong parameters!"
	echo "$0 DOMAIN"
	exit $EXIT_UNKNOW
fi

DOMAIN=$1

DNS=`dig $DOMAIN +short`
FILE=`cat /home/pi/ip.txt`

if [ ! "$DNS" ]; then
	echo "UNKNOW: Dig failed!"
	exit $EXIT_UNKNOW
fi
if [ ! "$FILE" ]; then
	echo "UNKNOW: Local file failed!"
	exit $EXIT_UNKNOW
fi

if [ "$DNS" == "$FILE" ]; then
	echo "OK: $DNS = $FILE"
	exit $EXIT_OK
fi
echo "CRITICAL: $DNS != $FILE"
exit $EXIT_CRITICAL
