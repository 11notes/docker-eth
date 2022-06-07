#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
        --datadir "/geth/var" \
        --config "/geth/etc/config.toml"  \
        --syncmode=snap \
        --cache 16384  \
        --txlookuplimit 0 \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api eth,web3 \
            --ws.origins '*' \
        --http \
            --http.addr 0.0.0.0 \
            --http.api eth,web3 \
            --http.corsdomain '*'

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