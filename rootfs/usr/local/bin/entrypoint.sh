#!/bin/bash

WAN_IP=$(curl -s ifconfig.me)

geth \
    --datadir "/eth/geth/var" \
    --config "/eth/geth/etc/config.toml"  \
    --syncmode=snap \
    --cache 65536  \
    --txlookuplimit 0 \
    --ws \
        --ws.addr 0.0.0.0 \
        --ws.api eth,web3,txpool \
        --ws.origins '*' \
    --http \
        --http.addr 0.0.0.0 \
        --http.api eth,web3,txpool \
        --http.corsdomain '*' \
    --log.json > /eth/var/log/geth.log 2>&1 &

until [ -f /eth/geth/var/geth/jwtsecret ]
do
    sleep 1
done

if [[ -z "${PRYSM_PORT}" ]]; then
    PRYSM_PORT=13000
fi



prysm \
    --accept-terms-of-use \
    --datadir "/eth/prysm/var" \
    --restore-target-dir "/eth/prysm/var" \
    --execution-endpoint http://127.0.0.1:8551 \
    --jwt-secret /eth/geth/var/geth/jwtsecret \
    --block-batch-limit 1024 \
    --p2p-max-peers 1024 \
    --slots-per-archive-point 8192 \
    --max-goroutines 65536 \
    --p2p-local-ip 0.0.0.0 \
    --p2p-tcp-port ${PRYSM_PORT} \
    --p2p-udp-port ${PRYSM_PORT} \
    --p2p-host-ip ${WAN_IP} \
    --log-format "json" > /eth/var/log/prysm.log 2>&1 &


    tail -f /eth/var/log/geth.log | sed 's/^/GETH: /' &
    tail -f /eth/var/log/prysm.log | sed 's/^/PRYSM: /'
