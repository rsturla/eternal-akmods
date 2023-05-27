#!/usr/bin/env bash

set -oeux pipefail

readonly LANG="${LANG:-en_US.UTF-8}"

readonly CERT_DIR=_certs

readonly IMAGE="quay.io/fedora-ostree-desktops/base"
readonly TAG="38"

mkdir -p "${PWD}/${CERT_DIR}"

# Bootstrap keys with a pre-existing image to avoid touching '/etc' or
# installing additional packages on host
podman run \
    --env="LANG=${LANG}" \
    --volume="${PWD}/${CERT_DIR}:/tmp/${CERT_DIR}:z" \
    --workdir="/tmp/${CERT_DIR}" \
    --entrypoint=/bin/sh \
    "${IMAGE}:${TAG}" -c \
    "sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular,updates-archive}.repo && \
     rpm-ostree install akmods && \
     kmodgenca --auto && \
     cp /etc/pki/akmods/private/private_key.priv eternal-akmods.priv.local && \
     cp /etc/pki/akmods/certs/public_key.der eternal-akmods.der.local"
