#!/bin/bash

# GET ABSOLUTE PATH
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}") 
cd $SCRIPT_RELATIVE_DIR 
ABSOLUTE_PATH=$(pwd)

# CHECK IF THERE IS INTERNET CONNECTION
function check_online
{
    ON_NOW=$(netcat -z -w 5 1.1.1.1 53 && echo "1" || echo "0")
	if [ "$ON_NOW" = "1" ]; then
		echo "$ON_NOW"
	else
		ping -q -c 1 -W 3 archlinux.org &> /dev/null && echo "1" || echo "0"
	fi
}

# SEND IFTTT REQUEST
function ifttt_request
{
    curl -o /dev/null -X POST -H "Content-Type: application/json" -d "{\"local-ip\": \"${LOCAL_IP}\"}" https://maker.ifttt.com/trigger/${EVENT_NAME}/json/with/key/${IFTTT_KEY}
    # echo "Running curl -o /dev/null -X POST -H "Content-Type: application/json" -d "{\"local-ip\": \"${LOCAL_IP}\"}" https://maker.ifttt.com/trigger/${EVENT_NAME}/json/with/key/${IFTTT_KEY}"
}

# CHECK FOR ONLINE STATUS
IS_ONLINE=$(check_online)
MAX_CHECKS=20
CHECKS=0

while [ "$IS_ONLINE" = "0" ]; do
	
	sleep 10;
    IS_ONLINE=$(check_online)

    CHECKS=$[ $CHECKS + 1 ]
    if [ $CHECKS -gt $MAX_CHECKS ]; then
        break
    fi
done

if [ "$IS_ONLINE" = "0" ]; then
    exit 1
fi

# GET THE LOCAL IP
source "${ABSOLUTE_PATH}/.env"
LOCAL_INET=$(ip a | grep ${INTERFACE_NAME} | grep inet | xargs)
LOCAL_INET=($LOCAL_INET)
LOCAL_IP=${LOCAL_INET[1]}

# SEND THE LOCAL IP TO IFTTT ON startup ARG
if [[ "$1" == "startup" ]]; then
	ifttt_request
    echo ${LOCAL_IP} > ${ABSOLUTE_PATH}/.ip_local.temp
    exit 0
fi

# COMPARE THE NEW IP TO THE OLD IP ON NON-STARTUP FLAG
OLD_LOCAL_IP=$(cat ${ABSOLUTE_PATH}/.ip_local.temp)

if [[ "$OLD_LOCAL_IP" == "$LOCAL_IP" ]]; then
    echo "ip hasn't changed"
else
	ifttt_request
fi

echo ${LOCAL_IP} > ${ABSOLUTE_PATH}/.ip_local.temp

exit 0
