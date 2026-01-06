FROM node:25-alpine

# Install apk dependencies
RUN apk add --no-cache bash kubectl && npm install -g zx

WORKDIR /usr/src/app

COPY site-state-transfer-job.mjs .

ENTRYPOINT []

CMD ["./site-state-transfer-job.mjs"]
