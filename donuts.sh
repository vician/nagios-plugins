#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

while getopts "hd:" opt; do
    case "$opt" in
    h)
        echo "UNKNOWN: Run as $0 domain"
        exit $EXIT_UNKNOW
        ;;
    d)  domain=$OPTARG
        ;;
	*)
		echo "UNWKNON: Wrong arguments"
		exit $EXIT_UNKNOW
    esac
done

if [ ! "$domain" ]; then
	echo "UNKNWON: Empty domain name!"
	exit $EXIT_UNKNOW
fi

file=/etc/knot/zones/$domain.zone

temp=$(mktemp)

sudo /usr/sbin/donuts -i DNSSEC_MISSING_RRSIG_RECORD2 $file $domain 2>&1 > $temp

COUNT=$(cat $temp | grep "Message:" | grep -v "RRSIG is nearing its expiration time" | wc -l)

if [ $COUNT -eq 0 ]; then
	echo "OK: No errors found"
	rm $temp
	exit $EXIT_OK
else
	echo -n "$COUNT ERRORS: "
	cat $temp | grep "Message:" | grep -v "RRSIG is nearing its expiration time" | awk '{$1=""; print $0}'
	rm $temp
	exit $EXIT_CRITICAL
fi

