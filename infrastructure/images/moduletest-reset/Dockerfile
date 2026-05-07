FROM node:26-alpine

# Install apk dependencies
RUN apk add --no-cache bash kubectl && npm install -g zx

WORKDIR /usr/src/app

COPY moduletest-reset.mjs .

ENTRYPOINT []

CMD ["./moduletest-reset.mjs"]
