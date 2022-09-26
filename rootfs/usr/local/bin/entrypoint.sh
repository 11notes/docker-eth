#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
        --datadir "/geth/var" \
        --config "/geth/etc/config.toml"  \
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
        --authrpc.vhosts '*' \
        --authrpc.jwtsecret /geth/etc/jwt


    exec "$@"
else
    case $1 in
        "prune")
            set -- "geth" \
                snapshot \
                prune-state \
                --datadir "/geth/var"

            exec "$@"
        ;;
    esac
fi