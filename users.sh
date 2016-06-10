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
COUNT_TMUX=$(who | grep 'tmux' | wc -l)
COUNT_SCREEN=$($who | grep 'S\.' | wc -l)

MESSAGE="$COUNT users ($COUNT_TMUX tmux, $COUNT_SCREEN screen)"

if [ -z "$COUNT" ]; then
	echo "Cannot detect number of connected users!"
	exit $EXIT_UNKNOW
fi

if [ $COUNT -lt $WARNING ]; then
	echo "OK: $MESSAGE"
	exit $EXIT_OK
fi

if [ $COUNT -lt $CRITICAL ]; then
	echo "WARNING: $MESSAGE"
	exit $EXIT_WARNING
fi

echo "CRITICAL: $MESSAGE"
exit $EXIT_CRITICAL
