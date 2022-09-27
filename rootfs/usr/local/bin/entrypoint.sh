#!/bin/sh

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
        --http.corsdomain '*' &

until [ -f /eth/geth/var/geth/jwtsecret ]
do
    echo "wait for geth IPC to be ready ..."
    sleep 1
done

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
    --p2p-host-ip ${WAN_IP} 