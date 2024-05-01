ARG TESLAMATE_TAG

FROM teslamate/grafana:${TESLAMATE_TAG} as grafana

#---

FROM teslamate/teslamate:${TESLAMATE_TAG}

ARG ARCH
ARG BASHIO_VERSION=0.16.2
ARG S6_OVERLAY_VERSION=3.1.6.2

ENV \
    DEBIAN_FRONTEND="noninteractive" \
    LANG="C.UTF-8" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1

USER root

# Commands taken from HA Ubuntu base Dockerfile but switched to wget as curl didn't work using buildx
# https://github.com/home-assistant/docker-base/blob/master/ubuntu/amd64/Dockerfile
RUN \
    set -x \
    && apt-get update && apt-get install -y --no-install-recommends \
        bash \
        bind9utils \
        ca-certificates \
        curl \
        jq \
        nginx \
        tzdata \
        wget \
        xz-utils

# From version 3.0.0.0 of S6-overlay, the amd64 architecture is renamed x86_64
RUN \
    set -x \
    && S6_ARCH=$(if [ "$ARCH" = "amd64" ]; then echo "x86_64"; else echo $ARCH; fi) \
    \
    && wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf s6-overlay-noarch.tar.xz \
    && rm s6-overlay-noarch.tar.xz \
    \
    && wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz \
    && tar -C / -Jxpf s6-overlay-${S6_ARCH}.tar.xz \
    && rm s6-overlay-${S6_ARCH}.tar.xz \
    \
    && wget https://github.com/just-containers/s6-overlay/releases/download/v3.1.6.2/s6-overlay-symlinks-noarch.tar.xz \
    && tar -C / -Jxpf s6-overlay-symlinks-noarch.tar.xz \
    && rm s6-overlay-symlinks-noarch.tar.xz

RUN \
    set -x \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && mkdir -p /tmp/bashio \
    && wget https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz \
    && tar xvzf v${BASHIO_VERSION}.tar.gz --strip 1 -C /tmp/bashio \
    && rm -f v${BASHIO_VERSION}.tar.gz \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio

COPY --chown=root --chmod=555 scripts/*.sh /

COPY --chown=root --chmod=555 services/teslamate/run services/teslamate/finish /etc/services.d/teslamate/

COPY --chown=root --chmod=555 services/nginx/run services/nginx/finish /etc/services.d/nginx/

COPY --chown=root services/nginx/teslamate.conf /etc/nginx/conf.d/

COPY --from=grafana --chown=root /dashboards /dashboards
COPY --from=grafana --chown=root /dashboards_internal /dashboards

# S6-Overlay
ENTRYPOINT ["/init"]