#!/bin/bash

GCP_SA_KEY=$1
KEYS=$2

for KEY in ${KEYS//,/ }
do
    echo "$KEY"
done

mkdir -p /tmp/certs
echo "$GCP_SA_KEY" > /tmp/certs/svc_account.json

gcloud auth activate-service-account --key-file=/tmp/certs/svc_account.json --project $(cat /tmp/certs/svc_account.json | jq -r '.project_id') --no-user-output-enabled

gcloud secrets list

gcloud secrets versions access latest --secret="DEVELOP_KEY" --format='get(payload.data)' | tr '_-' '/+' | base64 -d