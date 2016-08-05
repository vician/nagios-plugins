#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3


INCLUDE_SUBDOMAINS=0

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
	echo "WRONG parameters!"
	exit $EXIT_UNKNOW
fi

domain="https://$1"
if [ $# -eq 2 ]; then
	INCLUDE_SUBDOMAINS=1
fi

protocol=$2
if [ "$protocol" == "4" ] || [ "$protocol" == "6" ]; then
	protocol="-$protocol"
else
	echo "WRONG protocol: $protocol"
	exit $EXIT_UNKNOW
fi

hsts=$(curl $protocol -s -D- $domain 2>/dev/null | grep Strict 2>/dev/null)
if [ $? -ne 0 ]; then
	echo "ERROR: No HSTS!"
	exit $EXIT_CRITICAL
fi

if [ $INCLUDE_SUBDOMAINS -eq 1 ]; then
	echo $hsts | grep includeSubdomains 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "WARNING: HSTS enabled, but without subdomains!"
		exit $EXIT_WARNING
	else
		echo "OK: HSTS enabled with subdomains"
		exit $EXIT_OK
	fi
fi

echo "OK: HSTS enabled (subdomains not checked)"
exit $EXIT_OK
