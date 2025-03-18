FROM alpine:3.21.3

RUN apk add --no-cache nodejs npm

RUN npm install -g zx

RUN apk add curl

RUN curl -L "https://github.com/uselagoon/lagoon-cli/releases/download/v0.31.5/lagoon-cli-v0.31.5-linux-amd64" -o /usr/local/bin/lagoon && chmod +x /usr/local/bin/lagoon

RUN apk add bash

WORKDIR /usr/src/app

COPY redeploy-controller.mjs .

ENTRYPOINT []

CMD ["./redeploy-controller.mjs"]
