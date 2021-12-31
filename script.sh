#!/bin/bash

GCP_SA_KEY=$1
KEYS=$2

echo "Authenticating Service Account with gcloud..."
mkdir -p /tmp/certs
echo "$GCP_SA_KEY" > /tmp/certs/svc_account.json
gcloud auth activate-service-account --key-file=/tmp/certs/svc_account.json --project $(cat /tmp/certs/svc_account.json | jq -r '.project_id') --no-user-output-enabled

echo "Retrieving secrets from Secret Manager..."
for KEY in ${KEYS//,/ }
do
    echo "Retrieving secret for: $KEY"

    SECRET=$(gcloud secrets versions access latest --secret="$KEY" --format='get(payload.data)' | tr '_-' '/+' | base64 -d)

    if [ -z "$SECRET" ]; then
        exit 1
    fi

    # echo "::add-mask::$SECRET"

    echo "::set-output name=$KEY::$SECRET"
done
