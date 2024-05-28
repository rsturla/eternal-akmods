#!/bin/sh

set -oeux pipefail

curl -o /etc/yum.repos.d/negativo17-nvidia.repo https://negativo17.org/repos/fedora-nvidia.repo
