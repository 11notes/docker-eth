# :: Build
  FROM golang:alpine as build
  ENV checkout=v1.13.4

  RUN set -ex; \
    apk add --no-cache \
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
ENV APP_ROOT=/geth
COPY --from=build /go/go-ethereum/build/bin/ /usr/local/bin

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk --no-cache upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]