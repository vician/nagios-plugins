#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

if [ $# -ne 2 ]; then
	echo "ERROR: Wrong parameters!"
	echo "$0 WARNING CRITICAL"
	exit $EXIT_UNKNOW
fi

WARNING=$1
CRITICAL=$2

if [ $WARNING -ge $CRITICAL ]; then
	echo "ERROR: Warning has to be less then critical!"
	exit $EXIT_UNKNOW
fi

COUNT=$(who | grep -v 'tmux\|S\.' | wc -l)

if [ -z "$COUNT" ]; then
	echo "Cannot detect number of connected users!"
	exit $EXIT_UNKNOW
fi

if [ $COUNT -lt $WARNING ]; then
	echo "OK: $COUNT users"
	exit $EXIT_OK
fi

if [ $COUNT -lt $CRITICAL ]; then
	echo "WARNING: $COUNT users"
	exit $EXIT_WARNING
fi

echo "CRITICAL: $COUNT users"
exit $EXIT_CRITICAL
