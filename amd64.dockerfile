# :: Build
	FROM golang:alpine as geth
	ENV checkout=master

    RUN set -ex; \
        apk add --update --no-cache \
            curl \
            wget \
            unzip \
			build-base \
            linux-headers \
            make \
            cmake \
            g++ \
            git; \
        git clone https://github.com/ethereum/go-ethereum.git; \
        cd /go/go-ethereum; \
		git checkout ${checkout}; \
        make -j $(nproc);

# :: Header
	FROM alpine:3.16
	COPY --from=geth /go/go-ethereum/build/bin/ /usr/local/bin

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /geth; \
            mkdir -p /geth/etc; \
            mkdir -p /geth/var;

		RUN set -ex; \
			apk add --update --no-cache \
				curl \
				shadow;

		RUN set -ex; \
			addgroup --gid 1000 -S geth; \
			adduser --uid 1000 -D -S -h /geth -s /sbin/nologin -G geth geth;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R geth:geth \
				/geth

# :: Volumes
	VOLUME ["/geth/var"]

# :: Monitor
    RUN set -ex; chmod +x /usr/local/bin/healthcheck.sh
    HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER geth
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]