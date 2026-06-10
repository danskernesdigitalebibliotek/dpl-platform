ARG CLI_IMAGE
FROM ${CLI_IMAGE} as cli

FROM uselagoon/nginx-drupal:${LAGOON_IMAGES_RELEASE_TAG}

COPY --from=cli /app /app

# Following COPY blocks are taken from the nginx.dockerfile form the dpl-cms repo.
# They are used to add custom nginx configuration to the image.
# TODO: Find a better way of NOT duplicating this code.
COPY lagoon/conf/nginx/metrics /app/web/_metrics

# NB: pass the directory (not a *.conf glob) to fix-permissions — the script
# only operates on its first argument, so a glob would silently fix just one
# file and leave the rest non-group-writable, which breaks Lagoon's startup
# env-var substitution and crashes nginx.
COPY lagoon/conf/nginx/*.conf /etc/nginx/conf.d/drupal/
RUN fix-permissions /etc/nginx/conf.d/drupal/

# Define where the Drupal Root is located
ENV WEBROOT=cms/web
