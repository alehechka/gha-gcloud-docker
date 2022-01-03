#!/bin/bash

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