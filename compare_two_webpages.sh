#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

readonly MAX_REDIRECT=2


function help {
	echo "$0 [-h] -s HOST1 -r HOST2 -d DOMAIN -p PATH"
	exit $EXIT_UNKNOW
}

HOSTS=()
URLPATH=""
while getopts "s:r:d:h" opt; do
    case "$opt" in
    h)  
        help
        exit $EXIT_UNKNOW
        ;;
    d)  DOMAIN=$OPTARG
        ;;
    s)  HOST1=$OPTARG
        ;;
    r)  HOST2=$OPTARG
        ;;
    p)  URLPATH="$OPTARG"
        ;;
    *)  
        echo "UNWKNON: Wrong arguments"
        exit $EXIT_UNKNOW
    esac
done

if [ ! "$HOST1" ] || [ ! "$HOST2" ] || [ ! "$DOMAIN" ]; then
	echo "WRONG ARGUMENTS!"
	echo "Run $0 -h for help"
	exit $EXIT_UNKNOW
fi

#echo "hosts: ${HOSTS[*]}"

FILE1=$(mktemp)
FILE2=$(mktemp)

wget -O $FILE1 --header="Host: $DOMAIN" "$HOST1$URLPATH" --no-check-certificate --max-redirect $MAX_REDIRECT 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
	echo "CRITICAL: Cannot download $DOMAIN$URLPATH from $HOST1"
	rm $FILE1 $FILE2
	exit $EXIT_CRITICAL
fi
wget -O $FILE2 --header="Host: $DOMAIN" "$HOST2$URLPATH" --no-check-certificate --max-redirect $MAX_REDIRECT 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
	echo "CRITICAL: Cannot download $DOMAIN$URLPATH from $HOST2"
	rm $FILE1 $FILE2
	exit $EXIT_CRITICAL
fi

diff $FILE1 $FILE2
if [ $? -ne 0 ]; then
	echo "CRITICAL: Webpages aren't the same!"
	rm $FILE1 $FILE2
	exit $EXIT_CRITICAL
else
	echo "OK: Webpages are the same."
	rm $FILE1 $FILE2
	exit $EXIT_OK
fi
