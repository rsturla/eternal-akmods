#!/bin/sh

set -ouex pipefail

# Restore the original repo configuration
rm /etc/yum.repos.d/*
cp -a /tmp/yum.repos.d/* /etc/yum.repos.d/
rm -rf /tmp/yum.repos.d

semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

ln -sf /usr/bin/ld.bfd /etc/alternatives/ld
ln -sf /etc/alternatives/ld /usr/bin/ld

systemctl enable eternal-nvctk-cdi.service
