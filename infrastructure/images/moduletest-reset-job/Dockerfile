FROM node:24-alpine

# Install apk dependencies
RUN apk add --no-cache bash kubectl && npm install -g zx && apt-get install jq -y

WORKDIR /usr/src/app

COPY moduletest-reset-job.mjs .

ENTRYPOINT []

CMD ["./moduletest-reset-job.mjs"]
