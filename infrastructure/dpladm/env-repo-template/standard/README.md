# Core Test site "${LAGOON_PROJECT_NAME}"

This is the environment repository for the Core Test site ${LAGOON_PROJECT_NAME}

## Environment variables

The different applications services: CMS, GO and BNF depends on environment variables.
This list of env variables is incomplete - please add to it as you

### Is resolved by GO's start.sh script

NEXT_PUBLIC_APP_URL
NEXT_PUBLIC_GRAPHQL_SCHEMA_ENDPOINT_DPL_CMS
NEXT_PUBLIC_DPL_CMS_HOSTNAME

### Bliver sat i node.dockerfile found in this folder

NEXT_PUBLIC_GRAPHQL_SCHEMA_ENDPOINT_FBI
UNILOGIN_API_URL
UNILOGIN_CLIENT_ID
UNILOGIN_WELLKNOWN_URL
UNLILOGIN_PUBHUB_CLIENT_ID
UNLILOGIN_PUBHUB_RETAILER_ID
BNF_SERVER_GRAPHQL_ENDPOINT
NEXT_PUBLIC_PUBHUB_BASE_URL

### These are generated by infrastructure/task/scripts/create-update-node-env-variables.mjs

#### They are uniqe per project

GO_SESSION_SECRET

### These are generated by infrastructure/task/scripts/create-go-and-bnf-consumer-and-secrets.mjs

#### The values are identical across projects

DRUPAL_REVALIDATE_SECRET
BNF_GRAPHQL_CONSUMER_SECRET
BNF_GRAPHQL_CONSUMER_USER_PASSWORD
GO_GRAPHQL_CONSUMER_SECRET
GO_GRAPHQL_CONSUMER_USER_PASSWORD

### These variables are set by han in DPL CMS config form found at <https://dpl-cms-project-url.tld/admin/config/services/>

UNILOGIN_CLIENT_SECRET
UNLILOGIN_PUBHUB_RETAILER_KEY_CODE
UNILOGIN_MUNICIPALITY_ID
UNLILOGIN_SERVICES_WS_USER
UNLILOGIN_SERVICES_WS_PASSWORD

### Right now the GO application figures this one out, but it being deprecated

### (Should be deletable in july 2025)

NEXT_PUBLIC_GRAPHQL_BASIC_TOKEN_DPL_CMS
