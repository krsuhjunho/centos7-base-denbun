#!/bin/bash

SOURCE ./docker-run.sh
TODAY=$(date "+%Y-%m-%d")
Comment="$1"

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
git add . --ignore-removal
git commit -m "${TODAY} ${Comment}"
git config credential.helper store
git push origin main
}


MAIN()
{
DOCKER_IMAGE_BUILD
DOCKER_IMAGE_PUSH
GIT_COMMIT_PUSH
DOCKER_CONTAINER_REMOVE
DOCKER_CONTAINER_CREATE
DOCKER_CONTAINER_BASH
DOCKER_CONTAINER_URL_SHOW
}


MAIN
