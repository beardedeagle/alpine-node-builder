FROM alpine:3.12.1 as base_stage

LABEL maintainer="beardedeagle <randy@heroictek.com>"

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images.
ENV REFRESHED_AT=2020-10-23 \
  NODE_VER=15.0.1 \
  NPM_VER=7.0.3 \
  TERM=xterm \
  LANG=C.UTF-8

RUN set -xe \
  && apk --no-cache update \
  && apk --no-cache upgrade \
  && apk add --no-cache bash git libstdc++ openssl \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/* \
  && addgroup -g 1000 node \
  && adduser -u 1000 -G node -s /bin/sh -D node

FROM base_stage as deps_stage

RUN set -xe \
  && apk add --no-cache --virtual .build-deps \
    binutils-gold \
    curl \
    dpkg \
    dpkg-dev \
    g++ \
    gcc \
    gnupg \
    libgcc \
    linux-headers \
    make \
    musl \
    musl-dev \
    python3 \
    rsync \
    tar

FROM deps_stage as node_stage

RUN set -xe \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    1C050899334244A8AF75E53792EF661D867B9DFA \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VER}/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v${NODE_VER}.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v${NODE_VER}.tar.xz" \
    && cd "node-v${NODE_VER}" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
    && cd .. \
    && rm -rf "node-v${NODE_VER}*" SHASUMS256.txt.asc SHASUMS256.txt \
    && npm install --cache /tmp/npm_cache -g npm@"${NPM_VER}" \
    && rm -rf /tmp/npm_cache

FROM deps_stage as stage

COPY --from=node_stage /usr/local /opt/node

RUN set -xe \
  && rsync -a /opt/node/ /usr/local \
  && apk del .build-deps \
  && rm -rf /root/.cache \
  && rm -rf /var/cache/apk/*

FROM base_stage

COPY --from=stage /usr/local /usr/local
