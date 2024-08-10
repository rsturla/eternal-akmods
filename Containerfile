ARG FEDORA_VERSION=40
ARG KMOD_NAME=nvidia
ARG KMOD_VERSION=555
ARG FEDORA_KERNEL_FLAVOR=${FEDORA_VERSION}

FROM quay.io/fedora/fedora:${FEDORA_VERSION} AS builder

ARG FEDORA_VERSION
ARG KMOD_NAME
ARG KMOD_VERSION
ARG FEDORA_KERNEL_FLAVOR

COPY _certs /tmp/certs
COPY _scripts /tmp/scripts

RUN chmod +x /tmp/scripts/*.sh && \
    /tmp/scripts/replace-kernel.sh ${FEDORA_KERNEL_FLAVOR}

COPY kmods/${KMOD_NAME}/scripts/build /tmp/scripts
COPY kmods/${KMOD_NAME}/rpm-specs /tmp/rpm-specs
COPY kmods/${KMOD_NAME}/files /tmp/files

RUN chmod +x /tmp/scripts/*.sh && \
    /tmp/scripts/setup.sh && \
    /tmp/scripts/00-prebuild.sh && \
    /tmp/scripts/01-build.sh ${KMOD_VERSION} && \
    /tmp/scripts/final.sh

RUN rpm -ql /rpms/*.rpm


FROM scratch AS artifacts

ARG KMOD_NAME

COPY kmods/${KMOD_NAME}/scripts/install /scripts
COPY --from=builder /rpms /rpms
COPY --from=builder /var/cache/akmods/nvidia-vars /info/nvidia-vars
