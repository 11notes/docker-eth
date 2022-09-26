#!/bin/sh
    trap 'kill 0' SIGINT; 
        geth --datadir "/geth/var" \
            --config "/geth/etc/config.toml"  \
            --syncmode=snap \
            --cache 16384  \
            --txlookuplimit 0 \
            --ws \
                --ws.addr 0.0.0.0 \
                --ws.api eth,web3,txpool \
                --ws.origins '*' \
            --http \
                --http.addr 0.0.0.0 \
                --http.api eth,web3,txpool \
                --http.corsdomain '*' \
            --authrpc.vhosts '*' \
            --authrpc.jwtsecret /eth/etc/jwt &
        lighthouse bn \
            --network mainnet \
            --datadir /lighthouse/var \
            --execution-endpoint http://127.0.0.1:8545 \
            --execution-jwt /eth/etc/jwt