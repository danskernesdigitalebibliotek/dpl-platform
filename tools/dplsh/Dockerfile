ARG DPLSH_BUILD_VERSION=latest

# Use an intermediate images as a way to have dependabot track our dependency
# https://hub.docker.com/r/alpine/helm/tags?page=1&ordering=last_updated
FROM alpine/helm:3.19.0 as helm

# https://hub.docker.com/r/hashicorp/terraform/tags?page=1&ordering=last_updated
FROM hashicorp/terraform:1.13.4 as terraform

# We use the official azure cli as a base-image. It is itself based on alpine
# and is quite minimal.
# https://mcr.microsoft.com/v2/azure-cli/tags/list
FROM mcr.microsoft.com/azure-cli:2.63.0

# See https://github.com/go-task/task/releases
ARG TASK_VERSION=v3.40.0
# See https://github.com/uselagoon/lagoon-cli/releases
ARG LAGOON_CLI_RELEASE=v0.31.1

# The kubectl version can be bumped as we upgrade the cluster minor version.
ARG KUBECTL_VERSION=v1.29.5
# kubelogin is a client-go credential plugin implementing azure authentication.
# https://github.com/Azure/kubelogin/releases
ARG KUBELOGIN_VERSION=v0.0.34

LABEL org.opencontainers.image.source https://github.com/danskernesdigitalebibliotek/dpl-platform

SHELL ["/bin/bash", "-ox", "pipefail", "-c"]
WORKDIR /tmp

RUN az aks install-cli --kubelogin-version ${KUBELOGIN_VERSION} --client-version ${KUBECTL_VERSION}
RUN apk add --no-cache \
  bash-completion \
  ca-certificates \
  curl \
  docker-cli \
  gettext \
  git \
  github-cli \
  rsync \
  shadow \
  vim \
  yq \
  openssh \
  bind-tools \
  nodejs \
  npm

# Install zx
RUN npm install -g zx
# Add task, a modern Make equivalent.
RUN curl -sL https://taskfile.dev/install.sh | bash -s -- -b /usr/local/bin ${TASK_VERSION}

# Add the Lagoon CLI
RUN curl -Lo /usr/local/bin/lagoon https://github.com/uselagoon/lagoon-cli/releases/download/${LAGOON_CLI_RELEASE}/lagoon-cli-${LAGOON_CLI_RELEASE}-linux-amd64 \
  && chmod +x /usr/local/bin/lagoon
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
ENTRYPOINT ["dplsh-entrypoint.sh"]
