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

expire=$(dig $domain +dnssec +short | awk '{print $5}')

expire_year=$(echo ${expire:0:4})
expire_month=$(echo ${expire:4:2})
expire_day=$(echo ${expire:6:2})

expire_date="$expire_year-$expire_month-$expire_day"

verbose "expire: $expire => $expire_date"
verbose "=> $(date -d$expire_date)"

current=$(date +%Y%m%d%H%M%S)
current=$(date +%s)

verbose "current: $current"

# 
# 
# diff_s=$(expr $expire - $current)
# 
# verbose "diff sc: $diff_s"
# 
# diff_h=$(expr $diff_s / 3600)
# 
# verbose "diff hr: $diff_h"
# 
# diff_d=$(expr $diff_h / 24)
# 
# verbose "diff ds: $diff_d"
