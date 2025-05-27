FROM nvcr.io/nvidia/physicsnemo/physicsnemo:25.03

ENV DEBIAN_FRONTEND=noninteractive

# ┌─────────────────────────────────────────────────────────┐
# │     Download and install Vulkan 1.3 SDK                 │
# └─────────────────────────────────────────────────────────┘
#
ENV VULKAN_VERSION=1.3.296.0
ENV ARCH=x86_64
ENV VULKAN_SDK_URL=https://sdk.lunarg.com/sdk/download/1.3.296.0/linux
ENV VULKAN_SDK_FILENAME=vulkansdk-linux-${ARCH}-${VULKAN_VERSION}.tar.xz

WORKDIR /workspace/vulkan

# Download and extract Vulkan SDK
RUN wget ${VULKAN_SDK_URL}/${VULKAN_SDK_FILENAME} -O ${VULKAN_SDK_FILENAME} && \
    tar -xf ${VULKAN_SDK_FILENAME} && \
    rm ${VULKAN_SDK_FILENAME}

# Set up environment variables
ENV VULKAN_SDK=/workspace/vulkan/${VULKAN_VERSION}/${ARCH}
ENV PATH=${PATH}:${VULKAN_SDK}/bin
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${VULKAN_SDK}/lib
# ENV VK_ADD_LAYER_PATH=${VULKAN_SDK}/share/vulkan/explicit_layer.d${VK_ADD_LAYER_PATH:+:$VK_ADD_LAYER_PATH}"
# ENV VK_ICD_FILENAMES=${VULKAN_SDK}/etc/vulkan/icd.d
# ENV VK_LAYER_PATH=$VULKAN_SDK/etc/vulkan/explicit_layer.d

COPY docker/nvidia_icd.json /usr/share/vulkan/icd.d/

# ┌─────────────────────────────────────────────────────────┐
# │ Add sudo and allow the non-root user to execute         │
# │ commands as root without a password.                    │
# └─────────────────────────────────────────────────────────┘
#
ARG USER_NAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        sudo; \
    echo "$USER_NAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME; \
    chmod 0440 /etc/sudoers.d/$USER_NAME;


WORKDIR /workspace/

RUN git clone https://github.com/Alexey-Kamenev/Displacement-MicroMap-Toolkit.git && \
    cd Displacement-MicroMap-Toolkit    && \
    git submodule update --init --recursive --jobs 8    && \
    mkdir build                         && \
    cmake -S . -B ./build               && \
    make -C ./build/ -j
