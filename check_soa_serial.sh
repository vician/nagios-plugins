#!/bin/bash

readonly EXIT_OK=0
readonly EXIT_WARNING=1
readonly EXIT_CRITICAL=2
readonly EXIT_UNKNOW=3

VERBOSE=0

function verbose {
	if [ $VERBOSE -ne 1 ]; then
		return 0;
	fi
	echo $*
}

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
	echo "Missing parametr domain!"
	exit $EXIT_UNKNOW
fi
if [ $# -eq 2 ]; then
	VERBOSE=1
fi

domain=$1

while true ; do
	# Checking CNAME
	cname=$(dig +short $domain CNAME )
	if [ "$cname" ]; then
		# It is CNAME
		verbose "CNAME: $domain -> $cname"
		domain=$cname
	else
		verbose "Isn't CNAME"
		break
	fi
done

master=$(dig +short $domain SOA | awk '{print $1}')

dnss=($(dig $domain NS +short))

verbose "dns count: ${#dnss[@]}"

if [ ${#dnss[@]} -eq 0 ]; then
	echo "Cannot load NS records!"
	exit $EXIT_CRITICAL
fi

serials=()
for dns in ${dnss[@]}; do
	serial=$(dig $domain SOA +short @$dns | awk '{print $3}')
	if [ "$dns" == "$master" ] ; then
		master_serial=$serial
		verbose "- master: $dns"
	else
		serials+=($serial)
		verbose "- $dns"
	fi
done

verbose "checking:"
errors=0
error_message=""
id=0
for serial in ${serials[@]}; do
	verbose "- $serial against $master_serial"
	if [ "$serial" != "$master_serial" ]; then
		let errors++
		error_message="$error_message ${dnss[$id]} ($serial != $master_serial)"
		verbose "Are not the same!"
	fi
	let id++
done

if [ $errors -eq 1 ]; then
	echo "WARNING:$error_message"
	exit $EXIT_WARNING
fi
if [ $errors -gt 1 ]; then
	echo "CRITICAL:$error_message"
	exit $EXIT_CRITICAL
fi
echo "OK: All DNS have the same serial $master_serial"
exit $EXIT_OK
