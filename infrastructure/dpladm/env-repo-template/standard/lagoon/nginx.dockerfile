ARG CLI_IMAGE
FROM ${CLI_IMAGE} as cli

FROM uselagoon/nginx-drupal:${LAGOON_IMAGES_RELEASE_TAG}

COPY --from=cli /app /app

# Define where the Drupal Root is located
ENV WEBROOT=web
