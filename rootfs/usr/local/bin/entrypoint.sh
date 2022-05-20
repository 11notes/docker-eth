#!/bin/ash
if [ -z "$1" ]; then
    echo "starting eth ..."
    set -- "geth" \
        --datadir "/eth/var" \
        --config "/eth/etc/config.toml"  \
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
            echo "pruning eth ..."
            set -- "geth" \
                snapshot \
                prune-state \
                --datadir "/eth/var"

            exec "$@"
        ;;
    esac
fi