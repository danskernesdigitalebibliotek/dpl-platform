# List of available tags can be found here
# https://mcr.microsoft.com/v2/azure-cli/tags/list
ARG AZURE_CLI_TAG=latest
ARG DPLSH_BUILD_VERSION=latest

# Use an intermediate images as a way to have dependabot track our dependency
FROM alpine/helm:3.6.3 as helm
FROM hashicorp/terraform:1.0.6 as terraform

# We use the official azure cli as a base-image. It is itself based on alpine
# and is quite minimal.
FROM mcr.microsoft.com/azure-cli:$AZURE_CLI_TAG
ARG TASK_VERSION=v3.4.2
ARG STERN_RELEASE=1.11.0

LABEL org.opencontainers.image.source https://github.com/danskernesdigitalebibliotek/dpl-platform

SHELL ["/bin/bash", "-ox", "pipefail", "-c"]
WORKDIR /tmp

# TODO - this will install the latest version - we should pin to the version we
# actually use.
RUN az aks install-cli
RUN apk add --no-cache \
  ca-certificates \
  rsync \
  vim \
  gettext \
  bash-completion \
  docker-cli

# Add task, a modern Make equivalent.
RUN curl -sL https://taskfile.dev/install.sh | bash -s -- -b /usr/local/bin ${TASK_VERSION}

# Add Stern, a multi pod and container log tailing tool.
RUN curl -Lo /usr/local/bin/stern https://github.com/wercker/stern/releases/download/${STERN_RELEASE}/stern_linux_amd64 \
  && chmod +x /usr/local/bin/stern

WORKDIR /tmp

# Add Terraform
COPY --from=terraform /bin/terraform /bin/

# Add Helm
COPY --from=helm /usr/bin/helm /usr/bin/

# Create a dplsh user and switch to it to avoid running the shell as root
RUN adduser -D --shell /bin/bash dplsh

# We do this so that dplsh will be able to access /var/run/docker.sock
RUN chown dplsh /run && chgrp dplsh /run && chmod g+s /run

RUN echo "${DPLSH_BUILD_VERSION}" > /etc/dplsh.version

USER dplsh
WORKDIR /home/dplsh

# Install a tool for diffing charts
RUN helm plugin install https://github.com/databus23/helm-diff

# Add krew (plugin manager) to kubectl
RUN ( \
    set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" && \
    tar zxvf krew.tar.gz && \
    KREW=./krew-"${OS}_${ARCH}" && \
    "$KREW" install krew \
  )

ENV PATH=/home/dplsh/.krew/bin::$PATH

# Install a plugin for viewing secrets
RUN kubectl krew install view-secret

# Append our profile to the current one.
COPY files/dot.profile.sh /tmp/.profile.tmp
RUN cat /tmp/.profile.tmp >> /home/dplsh/.profile

# Entrypoint will copy mounted .azure-host to this dir if available
RUN mkdir /home/dplsh/.azure

# Place a copy of dplsh.sh in the image to support bootstrapping without
# installation.
# We have a tendency to mess around with this file during local development, so put it last
USER root
RUN mkdir /opt/dplsh
COPY dplsh.sh /opt/dplsh/

# Setup the entrypoint.
COPY files/dplsh-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/dplsh-entrypoint.sh
ENTRYPOINT [ "dplsh-entrypoint.sh"]

USER dplsh
