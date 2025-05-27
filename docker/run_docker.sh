#!/bin/bash

: ${IMAGE_NAME:="physicsnemo-remeshing"}
: ${IMAGE_TAG:="latest"}
: ${USER_NAME:="ubuntu"}
: ${CONTAINER_NAME:="physicsnemo-remeshing"}
: ${HOST_DATA_DIR:="/data"}
: ${CONTAINER_DATA_DIR:="/data"}

echo -e "\e[0;32m"
echo "Container name    : ${CONTAINER_NAME}"
echo "Host data dir     : ${HOST_DATA_DIR}"
echo "Container data dir: ${CONTAINER_DATA_DIR}"
echo -e "\e[0m"

CONTAINER_ID=`docker ps -aqf "name=^/${CONTAINER_NAME}$"`
if [ -z "${CONTAINER_ID}" ]; then
    echo "Creating new ${CONTAINER_NAME} container."
    docker run -it -d                                    \
        --gpus 'all,"capabilities=compute,utility,graphics"'      \
        --network=host                                   \
        --ipc=host                                       \
        --cap-add=SYS_PTRACE                             \
        -v /dev/shm:/dev/shm                             \
        -v ${HOST_DATA_DIR}:${CONTAINER_DATA_DIR}:rw     \
        -v /tmp/.X11-unix:/tmp/.X11-unix                 \
        -v /etc/localtime:/etc/localtime:ro              \
        -e DISPLAY=unix${DISPLAY}                        \
        --ulimit memlock=-1                              \
        --ulimit stack=67108864                          \
        --name=${CONTAINER_NAME}                         \
        ${IMAGE_NAME}:${IMAGE_TAG}

    CONTAINER_ID=`docker ps -aqf "name=^/${CONTAINER_NAME}$"`
else
    echo "Found ${CONTAINER_NAME} container: ${CONTAINER_ID}."
    # Check if the container is already running and start if necessary.
    if [ -z `docker ps -qf "name=^/${CONTAINER_NAME}$"` ]; then
        echo "Starting ${CONTAINER_NAME} container..."
        docker start ${CONTAINER_ID}
    fi
fi

docker exec --user ${USER_NAME} -it ${CONTAINER_ID} bash
