FROM ghcr.io/danskernesdigitalebibliotek/dpl-web-go:${GO_RELEASE} AS builder

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

# Credential for WeDoBooks' private npm registry, which serves the SDK behind
# the reader and the player. `build:stage2` below does not resolve any
# package - the base image was installed in dpl-web's stage 1 - so nothing
# needs this today. It is set anyway so that any pnpm command added to this
# stage, an install or a prune, works rather than failing on a 401 a long way
# from the cause.
#
# pnpm takes any config key from the environment as npm_config_<key>. Kept in
# the environment rather than written with `npm config set`, which would leave
# the token in an .npmrc in this layer. Either way it is discarded with the
# builder: the runner below copies /app and nothing else.
ARG WEDOBOOKS_NPM_TOKEN
ENV npm_config_//npm.pkg.wedobooks.io/:_authToken=$WEDOBOOKS_NPM_TOKEN

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN node ./scripts/prepare-docker-env-vars.mjs && \
    corepack enable && \
    pnpm run build:stage2

# Production image, copy all the files and run next
FROM uselagoon/node-${NODE_VERSION}:${LAGOON_IMAGES_RELEASE_TAG} AS runner

WORKDIR /app/go

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=10000:10000 /app /app
WORKDIR /app/go

CMD ["lagoon/start.sh"]
