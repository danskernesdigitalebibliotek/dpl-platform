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

# Host of the key-value store holding Prometheus metric counters. Hardcoded
# because it is static across all sites - Lagoon names the service after its
# compose entry - and set here rather than in docker-compose because Lagoon
# does not propagate compose-level `environment` to the deployed pods. Without
# it dpl_metrics falls back to per-process storage, which silently drops every
# counter: they are written by cron in the cli pod and read by php-fpm when
# Prometheus scrapes /metrics.
ENV METRICS_REDIS_HOST=redis-metrics

# App lives in /app/cms, so its Composer bin dir must be on PATH for drush and
# other vendored binaries (the base image only adds /app/vendor/bin).
ENV PATH=/app/cms/vendor/bin:$PATH
