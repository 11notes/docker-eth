# Alpine :: Ethereum
![size](https://img.shields.io/docker/image-size/11notes/eth/1.13.4?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/eth?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/eth?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-eth?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-eth?color=c91cb8)

Run an Ethereum node based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Volumes
* **/geth/etc** - Directory of config.toml
* **/geth/var** - Directory of all blockchain data

## Run
```shell
docker run --name eth \
  -v .../etc:/geth/etc \
  -v .../var:/geth/var \
  -d 11notes/eth:[tag]
```

```shell
# start container with custom configuration
docker run --name eth \
  -v ../geth/var:/geth/var \
  -d 11notes/eth:[tag] \
    geth \
      --datadir "/geth/var" \
      --config "/geth/etc/config.toml"  \
      --syncmode=snap \
      --cache 66560  \
      --bloomfilter.size 16384 \
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
      --nat extip:${ETH_WAN_IP} \
      --log.json \
      --metrics \
        --metrics.expensive \
        --metrics.influxdbv2 \
        --metrics.influxdb.endpoint "http://127.0.0.1:8086" \
        --metrics.influxdb.token "***********************" \
        --metrics.influxdb.organization "Ethereum" \
        --metrics.influxdb.bucket "eth" \
        --metrics.influxdb.tags "host=eth"

# stop container
docker stop -t 600 eth
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /geth | home directory of user docker |

## Parent image
* [11notes/alpine:stable](https://github.com/11notes/docker-alpine)

## Built with and thanks to
* [Ethereum](https://github.com/ethereum/go-ethereum)
* [Alpine Linux](https://alpinelinux.org/)

## Tips
* Increase cache as much as you can (64GB+ recommended)
* Don't kill container, stop gracefully with enough time to sync RAM to disk!
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)