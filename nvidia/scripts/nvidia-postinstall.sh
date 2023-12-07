#!/bin/sh

set -ouex pipefail

# Restore the original repo configuration
cp -a /tmp/yum.repos.d/* /etc/yum.repos.d/
rm -rf /tmp/yum.repos.d

semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

ln -s /usr/bin/ld.bfd /etc/alternatives/ld
ln -s /etc/alternatives/ld /usr/bin/ld
