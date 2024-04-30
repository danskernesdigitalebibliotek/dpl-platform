ARG CLI_IMAGE
FROM ${CLI_IMAGE} as cli

FROM uselagoon/nginx-drupal:${LAGOON_IMAGES_RELEASE_TAG}

COPY --from=cli /app /app


# Following COPY blocks are taken from the nginx.dockerfile form the dpl-cms repo.
# They are used to add custom nginx configuration to the image.
# TODO: Find a better way of NOT duplicating this code.
COPY lagoon/conf/nginx/location_prepend_drupal_authorize.conf /etc/nginx/conf.d/drupal/location_prepend_drupal_authorize.conf
RUN fix-permissions /etc/nginx/conf.d/drupal/location_prepend_drupal_authorize.conf

COPY lagoon/conf/nginx/server_append_drupal_authorize.conf /etc/nginx/conf.d/drupal/server_append_drupal_authorize.conf
RUN fix-permissions /etc/nginx/conf.d/drupal/server_append_drupal_authorize.conf

COPY lagoon/conf/nginx/server_append_drupal_modules_local.conf /etc/nginx/conf.d/drupal/server_append_drupal_modules_local.conf
RUN fix-permissions /etc/nginx/conf.d/drupal/server_append_drupal_modules_local.conf

COPY lagoon/conf/nginx/server_append_drupal_rewrite_registration.conf /etc/nginx/conf.d/drupal/server_append_drupal_rewrite_registration.conf
RUN fix-permissions /etc/nginx/conf.d/drupal/server_append_drupal_rewrite_registration.conf

# Define where the Drupal Root is located
ENV WEBROOT=web
