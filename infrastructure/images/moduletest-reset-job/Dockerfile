FROM node:25-alpine

# Install apk dependencies
RUN apk add --no-cache bash kubectl && npm install -g zx

WORKDIR /usr/src/app

COPY moduletest-reset-job.mjs .

ENTRYPOINT []

CMD ["./moduletest-reset-job.mjs"]
