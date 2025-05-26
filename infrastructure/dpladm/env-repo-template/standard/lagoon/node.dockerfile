FROM ghcr.io/danskernesdigitalebibliotek/dpl-go-node:${GO_RELEASE} as node

ENV NEXT_PUBLIC_GO_GRAPHQL_CONSUMER_USER_NAME=go_graphql
ENV BNF_GRAPHQL_CONSUMER_USER_NAME=bnf_graphql
ENV NEXT_PUBLIC_GRAPHQL_SCHEMA_ENDPOINT_FBI=https://fbi-api.dbc.dk/ereolgo/graphql
ENV UNILOGIN_WELLKNOWN_URL=https://broker.unilogin.dk/auth/realms/broker/.well-known/openid-configuration
ENV UNILOGIN_PUBHUB_RETAILER_ID=810
ENV UNILOGIN_PUBHUB_CLIENT_ID=EE939D96-702D-4BEE-AEB7-517B8BA18B15
ENV UNILOGIN_CLIENT_ID=https://ereolengo.dk/
ENV NEXT_PUBLIC_PUBHUB_BASE_URL=https://pubhub-openplatform.dbc.dk
ENV BNF_SERVER_GRAPHQL_ENDPOINT=askFini
