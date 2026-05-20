FROM ghcr.io/danskernesdigitalebibliotek/dpl-web-go:${GO_RELEASE} as builder

# Lagoon propagates build and global env variables as build-args.
ARG DRUPAL_REVALIDATE_SECRET
ARG DPL_GO_BASE_URL="https://${PRIMARY_GO_DOMAIN}"
ARG DPL_CMS_BASE_URL="https://${CMS_DOMAIN}"
ARG GO_SESSION_SECRET
ARG LAGOON_ENVIRONMENT
ARG LAGOON_PROJECT
ARG LAGOON_ROUTE
ARG LAGOON_ROUTES
ARG NEXT_PUBLIC_GO_GRAPHQL_CONSUMER_USER_PASSWORD
ARG UNLILOGIN_PUBHUB_RETAILER_ID
ARG UNLILOGIN_PUBHUB_RETAILER_KEY_CODE

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN node ./scripts/prepare-docker-env-vars.mjs && \
    yarn run build:stage2

# Production image, copy all the files and run next
FROM uselagoon/node-${NODE_VERSION}:${LAGOON_IMAGES_RELEASE_TAG} AS runner

WORKDIR /app/go

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=10000:10000 /app /app
WORKDIR /app/go

CMD ["lagoon/start.sh"]
