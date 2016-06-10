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

RESULT=$(sudo /usr/sbin/donuts -i DNSSEC_MISSING_RRSIG_RECORD2 $file $domain | grep "Errors Found:")
echo $RESULT | grep -i "Errors Found: 0" 1>/dev/null
if [ $? -eq 0 ]; then
	echo "OK: No errors found"
	exit $EXIT_OK
else
	#sudo /usr/sbin/donuts -i DNSSEC_MISSING_RRSIG_RECORD2 $file $domain | grep -i "Errors Found:"
	NUMBER=$(echo $RESULT | awk '{print $3}')
	echo -n "$NUMBER ERRORS: "
	sudo /usr/sbin/donuts -i DNSSEC_MISSING_RRSIG_RECORD2 $file $domain | grep "Message:" | awk '{$1=""; print $0}'
	exit $EXIT_CRITICAL
fi
