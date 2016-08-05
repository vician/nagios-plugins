#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3


if [ $# -ne 1 ]; then
	echo "WRONG parameters!"
	exit $EXIT_UNKNOW
fi

curl -s -D- $domain | grep Strict
