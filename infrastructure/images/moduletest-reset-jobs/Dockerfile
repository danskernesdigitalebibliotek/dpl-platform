FROM node:22-alpine

# Install apk dependencies
RUN apk add --no-cache bash=5.2.21-r0 kubectl=1.32.0-r0 && npm install -g zx

WORKDIR /usr/src/app

COPY moduletest-files-reset-job.mjs .

ENTRYPOINT []

CMD ["./moduletest-files-reset-job.mjs"]
