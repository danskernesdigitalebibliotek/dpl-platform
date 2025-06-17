FROM ghcr.io/danskernesdigitalebibliotek/dpl-go-node:${GO_RELEASE} as builder

ARG DRUPAL_REVALIDATE_SECRET
ARG GO_SESSION_SECRET
ARG NEXT_PUBLIC_APP_URL="https://${PRIMARY_GO_DOMAIN}"
ARG NEXT_PUBLIC_DPL_CMS_HOSTNAME="${PRIMARY_DOMAIN}"
ARG NEXT_PUBLIC_GO_GRAPHQL_CONSUMER_USER_PASSWORD
ARG NEXT_PUBLIC_GRAPHQL_SCHEMA_ENDPOINT_DPL_CMS="https://${PRIMARY_DOMAIN}/graphql"

ENV NEXT_TELEMETRY_DISABLED=1

RUN yarn run build

# Production image, copy all the files and run next
FROM uselagoon/node-20:latest AS runner
WORKDIR /app

ENV NODE_ENV=production
# Uncomment the following line in case you want to disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=10000:10000 /app .

CMD ["/app/lagoon/start.sh"]
