FROM ubuntu:20.04

WORKDIR /workspaces

# Default ENV
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Use the mirror protocol for a fast mirror
RUN sed -i -e 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//mirror:\/\/mirrors\.ubuntu\.com\/mirrors\.txt/' /etc/apt/sources.list

# Install docker, jq, socat
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        dbus \
        software-properties-common \
        gpg-agent \
        git \
        jq \
        socat \
        sudo \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io
# This is a development container.  Don't bother to clean up apt cache, this way we have it handy later

COPY .devcontainer/start_ha.sh /usr/local/bin/start_ha.sh

# Install dependencies for the add-on development below.  For example, if you're running Node.js,
# you may want something like the following...
# RUN apt-get install -y --no-install-recommends nodejs npm

# Generate a machine-id for this container
RUN rm /etc/machine-id && dbus-uuidgen --ensure=/etc/machine-id

ENV DEBIAN_FRONTEND=dialog
