#!/bin/bash

echo "PUBLIC_HOST_ADDR: ${PUBLIC_HOST_ADDR}"
echo "PUBLIC_HOST_PORT: ${PUBLIC_HOST_PORT}"
echo "PUBLIC_HOST_USER: ${PUBLIC_HOST_USER}"
echo "PROXY_PORT: ${PROXY_PORT}"
echo "DESTINATION_PORT: ${DESTINATION_PORT}"
echo 
if [[ -n "${PUBLIC_HOST_ADDR}" && \
  -n "${PUBLIC_HOST_PORT}" && \
  -n "${PUBLIC_HOST_USER}" && \
  -n "${PROXY_PORT}" && \
  -n "${DESTINATION_PORT}" ]]; then

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

    echo "=> Setting up authorized_keys"
    cp -f "/root/authorized_keys/keys" "/root/.ssh/authorized_keys"
    chmod 400 /root/.ssh/authorized_keys

    echo "=> Running rsyslog"
    sudo service rsyslog start

    echo "=> Running in public host mode"
    sudo service ssh start 

    echo "=> Setting up the reverse ssh tunnel"
    if [[ "${AUTO_SSH}" == "yes" ]];
    then
      SSH_BIN="autossh -M0 "
    else
      SSH_BIN="ssh -v"
    fi
    echo "${SSH_BIN} -NgR ${PROXY_PORT}:localhost:${DESTINATION_PORT} root@${PUBLIC_HOST_ADDR} -p ${PUBLIC_HOST_PORT} -i /root/private_key/key"
    ${SSH_BIN} -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NgR ${PROXY_PORT}:localhost:${DESTINATION_PORT} ${PUBLIC_HOST_USER}@${PUBLIC_HOST_ADDR} -p ${PUBLIC_HOST_PORT} -i /root/private_key/key
else
  exit -1
fi
