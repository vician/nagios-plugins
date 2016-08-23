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
        echo "Missing parametr directory!"
        exit $EXIT_UNKNOW
fi
if [ $# -eq 2 ]; then
        VERBOSE=1
fi

dir=$1
cd $dir

git_status=$(git status 2>&1)
if [ $? -ne 0 ]; then
	echo "UNKNOW: Failed to get status for $dir: $git_status"
	exit $EXIT_UNKNOW
fi

warning=""
critical=""

modified=$(git status -s 2>&1 | grep -E "^ M" 2>/dev/null | awk '{print $2 }' | sed -s ':a;N;$!ba;s/\n/, /g')
if [ "$modified" ]; then
	critical="${critical}Modified files: $modified! "
fi

not_commited=$(git status -s 2>&1 | grep -E "^A" 2>/dev/null | awk '{print $2 }' | sed -s ':a;N;$!ba;s/\n/, /g')
if [ "$not_commited" ]; then
	warning="${warning}Not commited changes: $not_commited! "
fi

untracked=$(git status -s 2>&1 | grep -E "^\?\?" | awk '{print $2 }' | sed -s ':a;N;$!ba;s/\n/, /g')
if [ "$untracked" ]; then
	critical="${critical}Untracked files: $untracked! "
fi

if [ "$critical" ]; then
	echo "CRITICAL: $critical$warning"
	exit $EXIT_CRITICAL
fi
if [ "$warning" ]; then
	echo "WARNING: $warning"
	exit $EXIT_WARNING
fi

echo "OK: No local changes."
exit $EXIT_OK
