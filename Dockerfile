FROM nvcr.io/nvidia/physicsnemo/physicsnemo:25.03

ENV DEBIAN_FRONTEND=noninteractive

# ┌─────────────────────────────────────────────────────────┐
# │ Download and install Vulkan 1.3 SDK.                    │
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

# Copy the driver file to enable NVIDIA GPUs.
COPY docker/nvidia_icd.json /usr/share/vulkan/icd.d/


# ┌─────────────────────────────────────────────────────────┐
# │ Install X11, GLFW.                                      │
# └─────────────────────────────────────────────────────────┘
#
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libx11-dev          \
        libxcb1-dev         \
        libxcb-keysyms1-dev \
        libxcursor-dev      \
        libxi-dev           \
        libxinerama-dev     \
        libxrandr-dev       \
        libxxf86vm-dev      \
        libvulkan-dev       \
        libglfw3-dev

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

# ┌─────────────────────────────────────────────────────────┐
# │ Clone the Toolkit and build it.                         │
# └─────────────────────────────────────────────────────────┘
#
RUN git clone https://github.com/Alexey-Kamenev/Displacement-MicroMap-Toolkit.git && \
    cd Displacement-MicroMap-Toolkit  && \
    git submodule update --init --recursive --jobs 8

# Build the toolkit
# sed comments out the line which errors out but is not used
# anywhere (advice from the Toolkit authors).
RUN cd Displacement-MicroMap-Toolkit  && \
    sed -i '/pfn_vkGetLatencyTimingsNV(device, swapchain, pTimingCount, pLatencyMarkerInfo);/s/^/\/\/ /' ./external/nvpro_core/nvvk/extensions_vk.cpp && \
    mkdir build                       && \
    cmake -S . -B ./build/            && \
    make -C ./build/ -j

RUN pip install --no-cache-dir \
    usd-core==24.11     \
    numpy               \
    numba               \
    py7zr

# Set path to the modules.
ENV PYTHONPATH="\
    /workspace/Displacement-MicroMap-Toolkit/build/micromesh_python:\
    ${PYTHONPATH}"
