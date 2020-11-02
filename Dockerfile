ARG TESLAMATE_TAG

FROM teslamate/grafana:${TESLAMATE_TAG} as grafana

#---

FROM teslamate/teslamate:${TESLAMATE_TAG}

ARG BASHIO_VERSION=0.9.0
ARG S6_OVERLAY_VERSION=1.22.1.0

USER root

# Install bashio - from https://github.com/home-assistant/docker-base/blob/master/alpine/amd64/Dockerfile
RUN apk add --no-cache \
        bash \
        jq \
        tzdata \
        ca-certificates \
        curl \
        bind-tools \
        \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" \
        | tar zxvf - -C / \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && mkdir -p /tmp/bashio \
    && curl -L -s https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz | tar -xzf - --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio

COPY --chown=root scripts/*.sh /
RUN chmod a+x /*.sh

COPY --from=grafana --chown=root /dashboards /dashboards
COPY --from=grafana --chown=root /dashboards_internal /dashboards

# USER nobody

ENTRYPOINT ["/ha-bootstrap.sh"]
CMD ["bin/teslamate", "start"]