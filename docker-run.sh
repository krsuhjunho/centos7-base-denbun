#!/bin/bash

DOCKER_CONTAINER_NAME="denbun-test"
CONTAINER_HOST_NAME="denbun-test"
SSH_PORT=22456
HTTP_PORT=8011
DENBUN_BASE_IMAGE_NAME="wnwnsgh/centos7-base-denbun"
SERVER_IP=$(curl -s ifconfig.me)
ADMIN_URL="cgi-bin/dnpwml/dnpwmlconfig.cgi?"
USER_URL="cgi-bin/dnpwml/dnpwmljs.cgi"
HTTP_BASE="http://"



docker rm -f ${DOCKER_CONTAINER_NAME}

docker run -tid --privileged=true \
-h "${CONTAINER_HOST_NAME}" \
--name="${DOCKER_CONTAINER_NAME}" \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /etc/localtime:/etc/localtime:ro \
-e TZ=Asia/Tokyo \
-p ${SSH_PORT}:22 -p ${HTTP_PORT}:80 \
${DENBUN_BASE_IMAGE_NAME}


#docker exec -it ${DOCKER_CONTAINER_NAME} /bin/bash


echo ""
echo "Admin URL => ${HTTP_BASE}${SERVER_IP}:${HTTP_PORT}/${ADMIN_URL}"
echo ""
echo "User  URL => ${HTTP_BASE}${SERVER_IP}:${HTTP_PORT}/${USER_URL}"
echo ""


