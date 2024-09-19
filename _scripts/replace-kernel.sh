#!/usr/bin/env bash

set -euox pipefail

FEDORA_KERNEL_FLAVOR="${FEDORA_KERNEL_FLAVOR}"

dnf install -y dnf-plugins-core rpmrebuild sbsigntools openssl skopeo jq

# <major>.<minor>.<patch>-<num>.fc<fedora_version>.<arch>
FEDORA_KERNEL_VERSION=$(skopeo inspect docker://quay.io/fedora-ostree-desktops/base:${FEDORA_VERSION} | jq -r '.Labels["ostree.linux"]')

case "$FEDORA_KERNEL_FLAVOR" in
  "stable")
    KERNEL_VERSION=$(skopeo inspect docker://quay.io/fedora/fedora-coreos:stable | jq -r '.Labels["ostree.linux"]')
    ;;
  "testing")
    KERNEL_VERSION=$(skopeo inspect docker://quay.io/fedora/fedora-coreos:testing | jq -r '.Labels["ostree.linux"]')
    ;;
  *)
    KERNEL_VERSION=${FEDORA_KERNEL_VERSION}
    ;;
esac

ARCH=$(uname -m)
KERNEL_VERSION="$(echo "$KERNEL_VERSION" | rev | cut -d . -f 2- | rev).${ARCH}"
KERNEL_MAJOR_MINOR_PATCH=$(echo "$KERNEL_VERSION" | cut -d '-' -f 1)
KERNEL_RELEASE="$(echo "$KERNEL_VERSION" | cut -d - -f 2 | cut -d . -f 1).$(echo "$KERNEL_VERSION" | cut -d - -f 2 | cut -d . -f 2)"
dnf install -y \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-modules-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-modules-core-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-modules-extra-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-devel-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-devel-matched-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-uki-virt-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-core-"$KERNEL_VERSION".rpm
