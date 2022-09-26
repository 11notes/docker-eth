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

# :: Build
	FROM rust:1.62.1-bullseye AS lighthouse
	ENV checkout=v3.1.0
    ENV FEATURES="gnosis,modern,slasher-lmdb"

    RUN set -ex; \
        apt-get update -y; \
        apt-get -y upgrade -y; \
        apt-get install -y \
            make \
            cmake \
            g++ \
            git \
            libclang-dev; \
        git clone https://github.com/sigp/lighthouse.git; \
        cd /lighthouse; \
		git checkout ${checkout}; \
        make -j $(nproc);


# :: Header
	FROM ubuntu:22.04
	COPY --from=geth /go/go-ethereum/build/bin/ /usr/local/bin
    COPY --from=lighthouse /usr/local/cargo/bin/lighthouse /usr/local/bin/lighthouse

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /eth/geth; \
            mkdir -p /eth/geth/etc; \
            mkdir -p /eth/geth/var; \
            mkdir -p /eth/lighthouse/etc; \
            mkdir -p /eth/lighthouse/var;

		RUN set -ex; \
            apt-get update -y; \
            apt-get -y upgrade -y; \
            apt-get install -y --no-install-recommends \
                libssl-dev \
                ca-certificates; \
            apt-get clean; \
            rm -rf /var/lib/apt/lists/*;

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
	VOLUME ["/eth/geth/var", "/eth/lighthouse/var"]


# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER eth
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]