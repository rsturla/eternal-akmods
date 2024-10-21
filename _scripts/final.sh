#!/usr/bin/env bash

set -oeux pipefail

mkdir -p /rpms
for rpm in $(find /var/cache -name '*.rpm'); do
  echo "Copying $rpm..."
  cp -a $rpm /rpms
done

sed -i -e 's/args = \["rpmbuild", "-bb"\]/args = \["rpmbuild", "-bb", "--buildroot", "#{build_path}\/BUILD"\]/g' /usr/local/share/gems/gems/fpm-*/lib/fpm/package/rpm.rb;
for rpm in $(find /var/cache/rpms/kmods -type f -name \*.rpm); do
  basename="$(basename ${rpm})"
  name="${basename%%-6*}"
  fpm --verbose -s rpm -t rpm -p ${rpm} -f --name ${name} ${rpm}; \
done

ls -l /rpms
