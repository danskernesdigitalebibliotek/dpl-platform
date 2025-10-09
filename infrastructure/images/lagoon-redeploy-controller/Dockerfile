FROM alpine:3.22.2

# Install apk dependencies
RUN apk add --no-cache nodejs npm curl bash openssh-client && npm install -g zx

# Install lagoon CLI
RUN curl -L "https://github.com/uselagoon/lagoon-cli/releases/download/v0.31.5/lagoon-cli-v0.31.5-linux-amd64" -o /usr/local/bin/lagoon && chmod +x /usr/local/bin/lagoon

# Install jq tool
RUN wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && chmod +x ./jq && cp jq /usr/bin

WORKDIR /usr/src/app

COPY redeploy-controller.mjs .

ENTRYPOINT []

CMD ["./redeploy-controller.mjs"]
