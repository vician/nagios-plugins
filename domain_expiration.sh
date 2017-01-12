#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

if [ $# -ne 3 ]; then
	echo "Wrong arguments, shoudl be $0 domain w_days c_days"
	exit $EXIT_UNKNOW
fi

domain=$1
warning=$2
critical=$3

if [ $warning -lt 0 ] || [ $critical -lt 0 ]; then
	echo "Warning and critical has to be greater than zero!"
	exit $EXIT_UNKNOW
fi

if [ $warning -le $critical ]; then
	echo "Warning has to be greater than critical!"
	exit $EXIT_UNKNOW
fi


# Count dots
dots=$(echo $domain | sed 's/[^\.]//g' | awk '{ print length }')
if [ $dots -ne 1 ]; then
	echo "Wrong tld, have to contains exactly one dot!"
	exit $EXIT_UNKNOW
fi

# Parse tld
tld=$(echo $domain | awk -F'.' '{print $2}')

if [ "$tld" = "cz" ]; then
	expiration=$(whois $domain | grep expire | awk '{print $2}')
	#echo $expiration
	if [ -z "$expiration" ]; then
		echo "Cannot get expiration date!"
		exit $EXIT_UNKNOW
	fi
	e_d=$(echo $expiration | awk -F'.' '{print $1}')
	e_m=$(echo $expiration | awk -F'.' '{print $2}')
	e_y=$(echo $expiration | awk -F'.' '{print $3}')
	exp_date_r=$(date -d $e_y-$e_m-$e_d +%F)
	exp_date=$(date -d $e_y-$e_m-$e_d +%s)
	#echo $exp_date_r
	#echo $exp_date
else
	echo "Unknown TLD"
	exit $EXIT_UNKNOW
fi

today_r=$(date)
today=$(date +%s)
#echo $today

diff=$(($exp_date - $today))
#echo $diff
days=$(( $diff / (60*60*24) ))
#echo $days

if [ $days -gt $warning ]; then
	echo "OK: $domain expire in $days days ($exp_date_r)."
	exit $EXIT_OK
elif [ $days -gt $critical ]; then
	echo "WARNING: $domain expire in $days days ($exp_date_r)."
	exit $EXIT_WARNING
elif [ $days -gt 0 ]; then
	echo "CRITICAL: $domain expire in $days days ($exp_date_r)."
	exit $EXIT_CRITICAL
elif [ $days -eq 0 ]; then
	echo "CRITICAL: $domain expired today ($exp_date_r)!"
	exit $EXIT_CRITICAL
else
	days=$(( $days * -1 ))
	echo "CRITICAL: $domain expired $days days ago ($exp_date_r)!"
	exit $EXIT_CRITICAL
fi
