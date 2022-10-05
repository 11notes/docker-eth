#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
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
            --http.corsdomain '*'
fi

exec "$@"