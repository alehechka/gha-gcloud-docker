#!/bin/bash

function main() {
    GCP_SA_KEY=$1
    KEYS=$2

    env | sort

    gcloud_auth "$GCP_SA_KEY" 

    get_secrets "$KEYS"
}

function gcloud_auth() {
    GCP_SA_KEY=$1
    PROJECT_ID=$(echo "$GCP_SA_KEY" | jq -r '.project_id')

    echo "Authenticating Service Account with gcloud..."
    mkdir -p /tmp/certs
    echo "$GCP_SA_KEY" > /tmp/certs/svc_account.json
    gcloud auth activate-service-account --key-file=/tmp/certs/svc_account.json --project "$PROJECT_ID" --no-user-output-enabled
}

function get_secrets() {
    KEYS=$1
    PREFIX=$(env_prefixer "$GITHUB_ACTION_REF" "$GITHUB_REF_TYPE")
    echo "$PREFIX"

    echo "Retrieving secrets from Secret Manager..."
    for KEY in ${KEYS//,/ }
    do
        echo "Retrieving secret for: $KEY"

        # https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets#access
        SECRET=$(gcloud secrets versions access latest --secret="$PREFIX$KEY" --format='get(payload.data)' | tr '_-' '/+' | base64 -d)

        if [ -z "$SECRET" ]; then
            exit 1
        fi

        # echo "::add-mask::$SECRET"

        echo "::set-output name=$KEY::$SECRET"
    done
}

function env_prefixer() {
    REF=$1
    REF_TYPE=$2

    PROD="PROD_"
    DEVELOP="DEVELOP_"

    # https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    # Semver official doesn't work with Bash, used this modified version: https://gist.github.com/rverst/1f0b97da3cbeb7d93f4986df6e8e5695#gistcomment-3029858
    SEMVER_REGEX="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$"

    if [ "$REF" = 'main' ]; then
        echo "$PROD"
    elif [[ "$REF_TYPE" = 'tag' ]] && [[ "$REF" =~ $SEMVER_REGEX ]]; then
        echo "TAG"
    else
        echo "$DEVELOP"
    fi
}

main "$@"; exit