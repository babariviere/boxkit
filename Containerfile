FROM quay.io/toolbx-images/alpine-toolbox:edge

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="me@babariviere.com"

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

COPY packages /
RUN apk update && \
    apk upgrade && \
    grep -v '^#' /packages | xargs apk add
RUN rm /packages

COPY go-packages /
RUN grep -v '^#' /go-packages | xargs -n1 go install
RUN rm /go-packages
RUN mv /root/go/bin/* /usr/local/bin/

COPY krew-plugins /
RUN grep -v '^#' /krew-plugins | xargs -n1 kubectl krew install
RUN rm /krew-plugins
RUN for bin in /root/.krew/bin/*; do \
      mv $(readlink $bin) /usr/local/bin/$(basename $bin); \
    done
RUN rm -rf /root/.krew

RUN   ln -fs /bin/sh /usr/bin/sh && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/op
