# This template contains variables for all aspects of the file that may change
# from site to site. Reversly it hardcodes any configuration that should be kept
# static across all sites.
FROM ${RELEASE_IMAGE_REPOSITORY}/${RELEASE_IMAGE_NAME}:${RELEASE_TAG} AS release

FROM uselagoon/php-8.0-cli-drupal:${LAGOON_IMAGES_RELEASE_TAG}

COPY --from=release /app /app
RUN mkdir -p -v -m775 /app/web/sites/default/files

# Define where the Drupal Root is located
ENV WEBROOT=web
