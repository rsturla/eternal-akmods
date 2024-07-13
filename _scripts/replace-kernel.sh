#!/usr/bin/env bash

set -euox pipefail

# Replace the kernel with the one from the Fedora repository
KERNEL_FLAVOR="${KERNEL_FLAVOR}"

dnf install -y dnf-plugins-core rpmrebuild sbsigntools openssl skopeo jq

case "$KERNEL_FLAVOR" in
  "stable")
    # <major>.<minor>.<patch>-<num>-fc<fedora_version>.<arch>
    KERNEL_VERSION=$(skopeo inspect docker://quay.io/fedora/fedora-coreos:stable | jq -r '.Labels["ostree.linux"]')
    ;;
  "testing")
    KERNEL_VERSION=$(skopeo inspect docker://quay.io/fedora/fedora-coreos:testing | jq -r '.Labels["ostree.linux"]')
    ;;
  *)
    KERNEL_VERSION=$(skopeo inspect docker://quay.io/fedora-ostree-desktops/base:${FEDORA_VERSION} | jq -r '.Labels["ostree.linux"]')
    ;;
esac

KERNEL_MAJOR_MINOR_PATCH=$(echo "$KERNEL_VERSION" | cut -d '-' -f 1)
KERNEL_RELEASE="$(echo "$KERNEL_VERSION" | cut -d - -f 2 | cut -d . -f 1).$(echo "$KERNEL_VERSION" | cut -d - -f 2 | cut -d . -f 2)"
ARCH=$(uname -m)
dnf download -y \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-modules-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-modules-core-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-modules-extra-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-devel-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-devel-matched-"$KERNEL_VERSION".rpm \
  https://kojipkgs.fedoraproject.org//packages/kernel/"$KERNEL_MAJOR_MINOR_PATCH"/"$KERNEL_RELEASE"/"$ARCH"/kernel-uki-virt-"$KERNEL_VERSION".rpm
