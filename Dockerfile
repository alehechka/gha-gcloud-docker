FROM google/cloud-sdk:alpine

RUN apk --update add jq

COPY script.sh /script.sh

ENTRYPOINT ["/script.sh"]