#!/bin/bash
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
    --authrpc.addr 127.0.0.1 \
    --authrpc.jwtsecret /eth/geth/etc/jwt &

until [ -f /eth/geth/etc/jwt ]
do
    echo "waiting for jwt file ..."
    sleep 5
done

lighthouse \
        bn \
        --network mainnet \
        --datadir /lighthouse/var \
        --execution-endpoint http://localhost:8551 \
        --execution-jwt /eth/geth/etc/jwt