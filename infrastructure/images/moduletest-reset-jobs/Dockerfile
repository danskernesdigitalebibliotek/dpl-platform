FROM node:22-alpine

# Install apk dependencies
RUN apk add --no-cache bash=5.2.37-r0 kubectl=1.32.2-r1 && npm install -g zx

WORKDIR /usr/src/app

COPY moduletest-files-reset-job.mjs .

ENTRYPOINT []

CMD ["./moduletest-files-reset-job.mjs"]
