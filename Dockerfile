FROM google/cloud-sdk:alpine

RUN apk --update add jq

COPY secret_manager.sh /secret_manager.sh
COPY env_prefixer.sh /env_prefixer.sh

ENTRYPOINT ["/secret_manager.sh"]