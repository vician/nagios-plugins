#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

URL=$1
EXPECTED=$2

REDIRECTION="$(curl $URL -s -L -I -o /dev/null --max-redirs 1 -w '%{url_effective}')"
#if [ $? -ne 0 ]; then
#	echo "CRITICAL Cannot detect redirect URL"
#	exit $EXIT_CRITICAL
#fi
if [ -z "$REDIRECTION" ]; then
	echo "No redirection!"
	exit $EXIT_CRITICAL
fi

if [ "$REDIRECTION" != "$EXPECTED" ]; then
	echo "CRITICAL: Rederirected to $REDIRECTION not to $EXPECTED"
	exit $EXIT_CRITICAL
fi

echo "OK: Redirected to $REDIRECTION"
exit $EXIT_OK
