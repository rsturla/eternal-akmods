#!/bin/sh

set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"

rpm-ostree install \
    akmod-nvidia*:${NVIDIA_VERSION}.*.fc${RELEASE} \
    xorg-x11-drv-nvidia-{,cuda,devel,kmodsrc,power}*:${NVIDIA_VERSION}.*.fc${RELEASE} \
    mock

# alternatives cannot create symlinks on its own during a container build
ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

if [[ ! -s "/tmp/certs/private_key.priv" ]]; then
    echo "WARNING: Using test signing key. Run './generate-akmods-key' for production builds."
    cp /tmp/certs/private_key.priv{.local,}
    cp /tmp/certs/public_key.der{.local,}
else
    echo "INFO: Using production signing key."
fi

install -Dm644 /tmp/certs/public_key.der  /etc/pki/akmods/certs/public_key.der
install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/certs/private_key.priv

# Either successfully build and install the kernel modules, or fail early with debug output
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(basename "$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")"
NVIDIA_LIB_VERSION="$(basename "$(rpm -q "xorg-x11-drv-nvidia" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")"
NVIDIA_FULL_VERSION="$(rpm -q "xorg-x11-drv-nvidia" --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}.%{ARCH}')"

akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"

modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
(cat /var/cache/akmods/nvidia/${NVIDIA_AKMOD_VERSION}-for-${KERNEL_VERSION}.failed.log && exit 1)

sed -i "s@gpgcheck=0@gpgcheck=1@" /tmp/nvidia-addons/rpmbuild/SOURCES/nvidia-container-toolkit.repo

install -D /etc/pki/akmods/certs/public_key.der /tmp/nvidia-addons/rpmbuild/SOURCES/public_key.der

rpmbuild -ba \
    --define '_topdir /tmp/nvidia-addons/rpmbuild' \
    --define '%_tmppath %{_topdir}/tmp' \
    /tmp/nvidia-addons/nvidia-addons.spec

cat <<EOF > /var/cache/akmods/nvidia-vars
KERNEL_VERSION=${KERNEL_VERSION}
RELEASE=${RELEASE}
NVIDIA_PACKAGE_NAME=nvidia
NVIDIA_MAJOR_VERSION=${NVIDIA_VERSION}
NVIDIA_FULL_VERSION=${NVIDIA_FULL_VERSION}
NVIDIA_AKMOD_VERSION=${NVIDIA_AKMOD_VERSION}
NVIDIA_LIB_VERSION=${NVIDIA_LIB_VERSION}
RPMFUSION_TESTING_ENABLED=${RPMFUSION_TESTING_ENABLED}
EOF
