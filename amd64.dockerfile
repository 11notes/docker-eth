# :: Build
	FROM golang:alpine as geth
	ENV ethVersion=v1.10.17

    RUN set -ex; \
        apk add --update --no-cache \
			build-base \
            linux-headers \
            make \
            cmake \
            g++ \
            git; \
        git clone https://github.com/ethereum/go-ethereum.git; \
        cd /go/go-ethereum; \
		git checkout ${ethVersion}; \
        make -j $(nproc);

# :: Header
	FROM alpine:3.14
	COPY --from=geth /go/go-ethereum/build/bin/ /usr/local/bin

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /eth; \
            mkdir -p /eth/etc; \
            mkdir -p /eth/var;

		RUN set -ex; \
			apk add --update --no-cache \
				curl \
                lz4 \
                tar \
                wget \
				shadow;

		RUN set -ex; \
			addgroup --gid 1000 -S eth; \
			adduser --uid 1000 -D -S -h /eth -s /sbin/nologin -G eth eth;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R eth:eth \
				/eth

# :: Volumes
	VOLUME ["/eth/etc", "/eth/var"]

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER eth
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]