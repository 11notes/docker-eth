#!/bin/ash
  if [ -z "$1" ]; then
    set -- "geth" \
      --datadir "/geth/var" \
      --config "/geth/etc/config.toml"  \
      --syncmode=snap \
      --cache 66560  \
      --txlookuplimit 0 \
      --ws \
        --ws.addr 0.0.0.0 \
        --ws.api net,eth,web3,txpool \
        --ws.origins '*' \
      --http \
        --http.addr 0.0.0.0 \
        --http.api net,eth,web3,txpool \
        --http.corsdomain '*' \
      --authrpc.addr 0.0.0.0 \
      --authrpc.port 8551 \
      --authrpc.vhosts '*' \
      --maxpeers 512 \
      --log.format=json
  fi

  exec "$@"