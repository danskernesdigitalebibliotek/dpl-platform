FROM ghcr.io/danskernesdigitalebibliotek/dpl-go-node:${GO_RELEASE} as builder

# Lagoon propagates build and global env variables as build-args.
ARG DRUPAL_REVALIDATE_SECRET
ARG GO_SESSION_SECRET
ARG NEXT_PUBLIC_APP_URL="https://${PRIMARY_GO_DOMAIN}"
ARG NEXT_PUBLIC_DPL_CMS_HOSTNAME="${CMS_DOMAIN}"
ARG NEXT_PUBLIC_GO_GRAPHQL_CONSUMER_USER_PASSWORD
ARG NEXT_PUBLIC_GRAPHQL_SCHEMA_ENDPOINT_DPL_CMS="https://${CMS_DOMAIN}/graphql"
ARG UNLILOGIN_PUBHUB_RETAILER_ID
ARG UNLILOGIN_PUBHUB_RETAILER_KEY_CODE

ENV NEXT_TELEMETRY_DISABLED=1

RUN yarn run build

# Production image, copy all the files and run next
FROM uselagoon/node-22:latest AS runner
WORKDIR /app

ENV NODE_ENV=production
# Uncomment the following line in case you want to disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=10000:10000 /app .

CMD ["/app/lagoon/start.sh"]
