ARG CLI_IMAGE
FROM ${CLI_IMAGE} as cli

FROM uselagoon/php-8.1-fpm:${LAGOON_IMAGES_RELEASE_TAG}

COPY --from=cli /app /app
