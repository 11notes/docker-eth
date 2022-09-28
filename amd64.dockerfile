# :: Build
	FROM golang:bullseye as geth
	ENV checkout=v1.10.25

    RUN set -ex; \
        apt update -y; \
        apt install -y \
            make \
            cmake \
            g++ \
            git; \
        git clone https://github.com/ethereum/go-ethereum.git; \
        cd /go/go-ethereum; \
		git checkout ${checkout}; \
        make -j $(nproc);

# :: Header
	FROM ubuntu:22.04
	COPY --from=geth /go/go-ethereum/build/bin/ /usr/local/bin
    ENV prysm=v3.1.1

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /eth/var/log; \
            mkdir -p /eth/geth/var; \
            mkdir -p /eth/prysm/var;

        ADD https://github.com/prysmaticlabs/prysm/releases/download/${prysm}/beacon-chain-${prysm}-linux-amd64 /usr/local/bin/prysm

		RUN set -ex; \
            apt-get update -y; \
            apt-get -y upgrade -y; \
            apt-get install -y --no-install-recommends \
                libssl-dev \
                curl \
                ca-certificates \
                tar; \
            apt-get clean; \
            rm -rf /var/lib/apt/lists/*; \
            chmod +x /usr/local/bin/prysm;


		RUN set -ex; \
            addgroup --gid 1000 eth; \
            useradd -d /eth -g 1000 -s /sbin/nologin -u 1000 eth;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R eth:eth \
				/eth

# :: Volumes
	VOLUME ["/eth/geth/var", "/eth/prysm/var", "/eth/var/log"]


# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER eth
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]