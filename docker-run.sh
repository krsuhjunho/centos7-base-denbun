#!/bin/bash

DOCKER_CONTAINER_NAME="denbun-test"
CONTAINER_HOST_NAME="denbun-test"
SSH_PORT=22456
HTTP_PORT=8081
DENBUN_BASE_IMAGE_NAME="wnwnsgh/centos7-base-denbun"

docker rm -f ${DOCKER_CONTAINER_NAME}

docker run -tid --privileged=true \
-h "${CONTAINER_HOST_NAME}" \
--name="${DOCKER_CONTAINER_NAME}" \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-p ${SSH_PORT}:22 -p ${HTTP_PORT}:80 \
${DENBUN_BASE_IMAGE_NAME}

docker exec -it ${DOCKER_CONTAINER_NAME} /bin/bash
