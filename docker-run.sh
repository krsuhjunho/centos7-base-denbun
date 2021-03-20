#!/bin/bash

#VAR
DOCKER_CONTAINER_NAME="denbun-test"
CONTAINER_HOST_NAME="denbun-test"
SSH_PORT=22456
HTTP_PORT=8011
BASE_IMAGE_NAME="ghcr.io/krsuhjunho/centos7-base-denbun"
SERVER_IP=$(curl -s ifconfig.me)
ADMIN_URL="cgi-bin/dnpwml/dnpwmlconfig.cgi?"
USER_URL="cgi-bin/dnpwml/dnpwmljs.cgi"
HTTP_BASE="http://"
TIME_ZONE="Asia/Tokyo"
TODAY=$(date "+%Y-%m-%d")
COMMIT_COMMENT="$2"
BUILD_OPTION="$1"

DOCKER_IMAGE_BUILD()
{
docker build -t ${BASE_IMAGE_NAME} .
}

DOCKER_IMAGE_PUSH()
{
docker push ${BASE_IMAGE_NAME}
}

GIT_COMMIT_PUSH()
{
git add -u
git commit -a -m "${TODAY} ${COMMIT_COMMENT}"
git config credential.helper store
git push origin main
}

DOCKER_CONTAINER_REMOVE()
{
docker rm -f ${DOCKER_CONTAINER_NAME}
}

DOCKER_CONTAINER_CREATE()
{
docker run -tid --privileged=true \
-h "${CONTAINER_HOST_NAME}" \
--name="${DOCKER_CONTAINER_NAME}" \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /etc/localtime:/etc/localtime:ro \
-e TZ=${TIME_ZONE} \
-p ${SSH_PORT}:22 -p ${HTTP_PORT}:80 \
${BASE_IMAGE_NAME}
}

DOCKER_CONTAINER_BASH()
{
docker exec -it ${DOCKER_CONTAINER_NAME} /bin/bash
}

DOCKER_CONTAINER_URL_SHOW()
{
echo ""
echo "Admin URL => ${HTTP_BASE}${SERVER_IP}:${HTTP_PORT}/${ADMIN_URL}"
echo ""
echo "User  URL => ${HTTP_BASE}${SERVER_IP}:${HTTP_PORT}/${USER_URL}"
echo ""
}

MAIN()
{

if [ "$BUILD_OPTION" == "--build" ]; then
    DOCKER_IMAGE_BUILD
	DOCKER_IMAGE_PUSH
	GIT_COMMIT_PUSH
fi

DOCKER_CONTAINER_REMOVE
DOCKER_CONTAINER_CREATE
#DOCKER_CONTAINER_BASH
DOCKER_CONTAINER_URL_SHOW
}

MAIN
