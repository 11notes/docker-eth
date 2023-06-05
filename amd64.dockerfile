# :: Build
  FROM golang:alpine as build
  ENV checkout=v1.12.0

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
FROM 11notes/alpine:stable
COPY --from=build /go/go-ethereum/build/bin/ /usr/local/bin

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk update; \
      apk upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p /geth; \
      mkdir -p /geth/etc; \
      mkdir -p /geth/var;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d /geth docker; \
      chown -R 1000:1000 \
        /geth;

# :: Volumes
  VOLUME ["/geth/etc", "/geth/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]