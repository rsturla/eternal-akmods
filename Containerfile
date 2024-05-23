FROM quay.io/fedora-ostree-desktops/base:40 as builder

ARG KMOD_DIR=nvidia
ARG KMOD_VERSION=550

COPY _certs /tmp/certs
COPY kmods /tmp/kmods

# chmod +x all *.sh in /tmp/kmods recursively
RUN find /tmp/kmods -type f -name "*.sh" -exec chmod +x {} \;
RUN /tmp/kmods/_setup.sh
RUN /tmp/kmods/${KMOD_DIR}/build.sh ${KMOD_VERSION}
RUN /tmp/kmods/_postbuild.sh


FROM scratch

COPY --from=builder /rpms /rpms
