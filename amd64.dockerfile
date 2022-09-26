# :: Build
	FROM golang:bullseye as geth
	ENV gethVersion=v1.10.25

    RUN set -ex; \
        apt update -y; \
        apt install -y \
            make \
            cmake \
            g++ \
            git; \
        git clone https://github.com/ethereum/go-ethereum.git; \
        cd /go/go-ethereum; \
		git checkout ${gethVersion}; \
        make -j $(nproc);

# :: Header
	FROM ubuntu:22.04
	COPY --from=geth /go/go-ethereum/build/bin/ /usr/local/bin

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /eth/geth; \
            mkdir -p /eth/geth/etc; \
            mkdir -p /eth/geth/var; \
            mkdir -p /eth/prysm/bin; \
            mkdir -p /eth/prysm/etc; \
            mkdir -p /eth/prysm/var;

		RUN set -ex; \
			apt update -y; \
            apt install -y \
				curl;

        RUN set -ex; \
            curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output /eth/prysm/bin/prysm && chmod +x /eth/prysm/bin/prysm;

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
	VOLUME ["/geth/var"]


# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER eth
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]