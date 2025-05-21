FROM node:24-alpine

# Install apk dependencies
RUN apk add --no-cache bash kubectl && npm install -g zx
RUN curl -L -o /usr/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux64

WORKDIR /usr/src/app

COPY moduletest-reset-job.mjs .

ENTRYPOINT []

CMD ["./moduletest-reset-job.mjs"]
