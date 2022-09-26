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
    --authrpc.addr 0.0.0.0 \
    --authrpc.vhosts '*' \
    --authrpc.jwtsecret /eth/geth/etc/jwt &

PRYSM_ALLOW_UNVERIFIED_BINARIES=1 /eth/prysm/bin/prysm beacon-chain \
    --datadir="/eth/prysm/var"\
    --execution-endpoint=http://localhost:8551 \
    --jwt-secret=/eth/geth/etc/jwt --accept-terms-of-use