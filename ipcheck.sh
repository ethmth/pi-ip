#!/bin/bash

# GET ABSOLUTE PATH
SCRIPT_RELATIVE_DIR=$(dirname "${BASH_SOURCE[0]}") 
cd $SCRIPT_RELATIVE_DIR 
ABSOLUTE_PATH=$(pwd)

# CHECK IF THERE IS INTERNET CONNECTION
function check_online
{
    netcat -z -w 5 1.1.1.1 53 && echo 1 || echo 0
}

IS_ONLINE=$(check_online)

MAX_CHECKS=20
CHECKS=0

while [ $IS_ONLINE -eq 0 ]; do

    sleep 10;
    IS_ONLINE=$(check_online)

    CHECKS=$[ $CHECKS + 1 ]
    if [ $CHECKS -gt $MAX_CHECKS ]; then
        break
    fi
done

if [ $IS_ONLINE -eq 0 ]; then
    exit 1
fi

# GET THE LOCAL IP

source "${ABSOLUTE_PATH}/.env"

IP_ADDRESS=$(ip a | grep ${INTERFACE_NAME} | grep inet)

echo ${IP_ADDRESS} > ${ABSOLUTE_PATH}/ip.temp

IP_ADDRESS=$(cat ${ABSOLUTE_PATH}/ip.temp)

# SEND THE LOCAL IP TO IFTTT ON startup ARG

if [[ "$1" == "startup" ]]; then
    curl -o /dev/null -X POST -H "Content-Type: application/json" -d "{\"ip-info\": \"${IP_ADDRESS}\"}" https://maker.ifttt.com/trigger/pi_awoken/json/with/key/${IFTTT_KEY}

    echo ${IP_ADDRESS} > ${ABSOLUTE_PATH}/ip.state

    exit 0
fi

# COMPARE THE NEW IP TO THE OLD IP ON NON-STARTUP FLAG

OLD_IP_ADDRESS=$(cat ${ABSOLUTE_PATH}/ip.state)

if [[ "$OLD_IP_ADDRESS" == "$IP_ADDRESS" ]]; then
    echo "ip hasn't changed"
else
    curl -o /dev/null -X POST -H "Content-Type: application/json" -d "{\"ip-info\": \"${IP_ADDRESS}\"}" https://maker.ifttt.com/trigger/pi_awoken/json/with/key/${IFTTT_KEY}
fi

echo ${IP_ADDRESS} > ${ABSOLUTE_PATH}/ip.state

exit 0