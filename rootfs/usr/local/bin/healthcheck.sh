#!/bin/ash
curl --max-time 5 -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' http://localhost:8545 || exit 1