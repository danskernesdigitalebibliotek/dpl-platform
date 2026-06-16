# This template contains variables for all aspects of the file that may change
# from site to site. Reversly it hardcodes any configuration that should be kept
# static across all sites.
FROM ${RELEASE_IMAGE_REPOSITORY}/${RELEASE_IMAGE_NAME}:${RELEASE_TAG} AS release

FROM uselagoon/php-${PHP_VERSION}-cli-drupal:${LAGOON_IMAGES_RELEASE_TAG}

COPY --from=release /app /app
RUN mkdir -p -v -m775 /app/cms/web/sites/default/files
# install kubectl - we need as long as we cant set the resource request
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# Define where the Drupal Root is located. Lagoon prefixes this with /app/.
ENV WEBROOT=cms/web

# App lives in /app/cms, so its Composer bin dir must be on PATH for drush and
# other vendored binaries (the base image only adds /app/vendor/bin).
ENV PATH=/app/cms/vendor/bin:$PATH
