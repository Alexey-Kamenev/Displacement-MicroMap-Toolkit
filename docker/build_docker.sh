#!/bin/bash

: ${IMAGE_NAME:="physicsnemo-remeshing"}
: ${IMAGE_TAG:="latest"}
: ${IMAGE_FULL_NAME:="${IMAGE_NAME}:${IMAGE_TAG}"}

DOCKER_DIR=$(dirname $(realpath -s $0))
REPO_DIR=$(realpath ${DOCKER_DIR}/../)

echo -e "\e[0;32m"
echo "Building image: ${IMAGE_FULL_NAME}"
echo "Repo directory: ${REPO_DIR}"
echo -e "\e[0m"

docker build \
    -t ${IMAGE_FULL_NAME}       \
    --network=host              \
    -f ${REPO_DIR}/Dockerfile \
    ${REPO_DIR}/

# docker push ${IMAGE_FULL_NAME}
