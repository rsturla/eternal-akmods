#!/bin/sh

set -oeux pipefail

# Disable repos that are not needed for the build to improve build times
if [[ "${FEDORA_VERSION}" -lt 39 ]]; then
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-modular}.repo
else
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
fi

# If COREOS_KERNEL is not set to 'N/A', replace the kernel with the specified version
if [[ "${COREOS_KERNEL}" != "N/A" ]]; then
  KERNEL_VERSION="${COREOS_KERNEL}"
  KERNEL_MAJOR_MINOR_PATCH=$(echo "${KERNEL_VERSION}" | cut -d '-' -f 1)
  KERNEL_RELEASE=$(echo "${KERNEL_VERSION}" | cut -d '-' -f 2)
  rpm-ostree override replace --experimental \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-core-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-modules-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-modules-core-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm" \
    "https://kojipkgs.fedoraproject.org//packages/kernel/${KERNEL_MAJOR_MINOR_PATCH}/${KERNEL_RELEASE}/x86_64/kernel-modules-extra-${KERNEL_MAJOR_MINOR_PATCH}-${KERNEL_RELEASE}.x86_64.rpm"
fi

rpm-ostree install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

rpm-ostree install \
  rpmfusion-free-release \
  rpmfusion-nonfree-release \
  --uninstall rpmfusion-free-release-$(rpm -E %fedora)-1.noarch \
  --uninstall rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch

# If RPMFUSION_TESTING_ENABLED is set to true, enable the RPMFusion testing repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
if [[ "${RPMFUSION_TESTING_ENABLED}" == "true" ]]; then
  echo "INFO: Enabling RPMFusion testing repositories"
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/rpmfusion-{free,nonfree}-updates-testing.repo
fi

sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/fedora-updates-archive.repo
