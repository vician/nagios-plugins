#!/bin/bash

#################################################################
# Creation: Edouard Lamoine
# Last Modification:6 mai 2015
# This script is verifying if UFW is active or not
#################################################################

#Memo for Nagios outputs
#STATE_OK=0
#STATE_WARNING=1
#STATE_CRITICAL=2
#STATE_UNKNOWN=3
#STATE_DEPENDENT=4


STATE=$(ufw status)

        if [[ ! $STATE =~ "active" ]];
        then
        echo "UNKNOWN - Impossible to determine UFW status"
        exit 3
        fi

        if [[ $STATE =~ "inactive" ]];
        then
        echo "CRITICAL - UFW is inactive"
        exit 2
        fi

        if [[ $STATE =~ "active" ]];
        then
        echo "OK - UFW is active"
        exit 0
        fi

