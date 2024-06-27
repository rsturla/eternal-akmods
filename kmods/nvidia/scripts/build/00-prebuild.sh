#!/bin/sh

set -oeux pipefail

curl -L https://negativo17.org/repos/fedora-nvidia.repo \
    -o /etc/yum.repos.d/negativo17-fedora-nvidia.repo
