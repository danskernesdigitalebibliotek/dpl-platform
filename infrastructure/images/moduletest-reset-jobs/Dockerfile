FROM alpine:3.21.3

# Install apk dependencies
RUN apk add --no-cache nodejs npm bash kubectl && npm install -g zx

WORKDIR /usr/src/app

COPY moduletest-files-reset-job.mjs .

ENTRYPOINT []

CMD ["./moduletest-files-reset-job.mjs"]
