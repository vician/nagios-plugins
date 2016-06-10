#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

if [ $# -ne 1 ]; then
	echo "Wrong parameters!"
	exit $EXIT_UNKNOW
fi

DOMAIN=$1

PROGRAM="/etc/nagios/swede/swede"

if [ ! -f "$PROGRAM" ]; then
	echo "Cannot find swede!"
	exit $EXIT_UNKNOW
fi

TLSA=$(dig +short _443._tcp.$DOMAIN. TLSA)

if [ -z "$TLSA" ]; then
	echo "WARNING: TLSA not found for $DOMAIN!"
	exit $EXIT_WARNING
fi

$PROGRAM verify $DOMAIN 1>/dev/null 2>/dev/null


if [ $? -ne 0 ]; then
	echo "Error: Broken TLSA for $DOMAIN!"
	exit $EXIT_CRITICAL
else
	echo "Correct TLSA for $DOMAIN"
	exit $EXIT_OK
fi
