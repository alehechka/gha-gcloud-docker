#!/bin/bash

GCP_SA_KEY=$1
PROJECT_ID=$(echo "$GCP_SA_KEY" | jq -r '.project_id')
KEYS=$2
PREFIX=$(env_prefixer.sh "$GITHUB_ACTION_REF" "$GITHUB_REF_TYPE")

echo "Authenticating Service Account with gcloud..."
mkdir -p /tmp/certs
echo "$GCP_SA_KEY" > /tmp/certs/svc_account.json
gcloud auth activate-service-account --key-file=/tmp/certs/svc_account.json --project "$PROJECT_ID" --no-user-output-enabled

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

env | sort
