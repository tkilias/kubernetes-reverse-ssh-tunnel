#!/bin/bash

if [ "${PUBLIC_HOST_ADDR}" == "**None**" ]; then
    unset PUBLIC_HOST_ADDR
fi

if [ "${PUBLIC_HOST_PORT}" == "**None**" ]; then
    unset PUBLIC_HOST_PORT
fi

if [ "${PROXY_PORT}" == "**None**" ]; then
    unset PROXY_PORT
fi

if [ "${DESTINATION_PORT}" == "**None**" ]; then
    unset DESTINATION_PORT
fi

if [[ -n "${PUBLIC_HOST_ADDR}" && -n "${PUBLIC_HOST_PORT}" ]]; then
    echo "=> Running in NATed host mode"
    if [ -z "${PROXY_PORT}" ]; then
        echo "PROXY_PORT needs to be specified!"
    fi

    echo "=> Connecting to Remote SSH servier ${PUBLIC_HOST_ADDR}:${PUBLIC_HOST_PORT}"

    KNOWN_HOSTS="/root/.ssh/known_hosts"
    if [ !-f ${KNOWN_HOST} ]; then
        echo "=> Scaning and save fingerprint from the remote server ..."
        ssh-keyscan -p ${PUBLIC_HOST_PORT} -H ${PUBLIC_HOST_ADDR} > ${KNOWN_HOSTS}
        if [ $(stat -c %s ${KNOWN_HOSTS}) == "0" ]; then
            echo "=> cannot get fingerprint from remote server, exiting ..."
            exit 1
        fi
        else
        echo "=> Fingerprint of remote server found, skipping"
    fi
    echo "====REMOTE FINGERPRINT===="
    cat ${KNOWN_HOSTS}
    echo "====REMOTE FINGERPRINT===="

    echo "=> Setting up the reverse ssh tunnel"
    echo "autossh -M 0 -NgR ${PROXY_PORT}:localhost:${DESTINATION_PORT} root@${PUBLIC_HOST_ADDR} -p ${PUBLIC_HOST_PORT} -i /root/private_key/key"
    autossh -M 0 -NgR ${PROXY_PORT}:localhost:${DESTINATION_PORT} root@${PUBLIC_HOST_ADDR} -p ${PUBLIC_HOST_PORT} -i /root/private_key/key
else
    echo "=> Running in public host mode"
    /usr/sbin/sshd -D
fi
