FROM uselagoon/lagoon-cli:latest
WORKDIR /

RUN wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN chmod +x ./jq
RUN cp jq /usr/bin

COPY ./redeploy.sh /redeploy.sh
RUN chmod +x /redeploy.sh

ENTRYPOINT ["/bin/sh", "-c", "/redeploy.sh"]
