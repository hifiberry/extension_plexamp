# Stage 1: Build busybox with lsof
FROM debian:bullseye as builder

# Install dependencies for building busybox
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libncurses5-dev \
    bison \
    flex

# Set environment variables
ENV BUSYBOX_VERSION=1.35.0

# Download, extract, configure, and compile BusyBox
RUN wget https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2 && \
    tar -xvjf busybox-${BUSYBOX_VERSION}.tar.bz2 && \
    cd busybox-${BUSYBOX_VERSION} && \
    make defconfig && \
    sed -i 's/CONFIG_DESKTOP=n/CONFIG_DESKTOP=y/' .config && \
    sed -i 's/# CONFIG_LSOF is not set/CONFIG_LSOF=y/' .config && \
    sed -i '/CONFIG_.*=y/!s/# \(CONFIG_.*\) is not set/\1=n/' .config && \
    sed -i 's/CONFIG_BUILD_LIBBUSYBOX=y/CONFIG_BUILD_LIBBUSYBOX=n/' .config && \
    make oldconfig && \
    make -j$(nproc) && \
    make install

FROM node:20-bullseye-slim 

ARG PLEXAMP_BUILD_VERSION=4.10.1
RUN apt -y update \
  && apt -y upgrade \
  && apt -y install --no-install-recommends bzip2 alsa-utils liblo-dev jq curl ca-certificates expect \
  && groupadd -g 2000 plexamp \
  && useradd -g 2000 -u 2002 -s /bin/bash -d /home/plexamp -G audio plexamp \
  && mkdir /app \
  && curl -o /tmp/plexamp-linux.tbz2 -L https://plexamp.plex.tv/headless/Plexamp-Linux-headless-v${PLEXAMP_BUILD_VERSION}.tar.bz2 \
  && tar -jxvf /tmp/plexamp-linux.tbz2 -C /app \
  && rm -f /tmp/*.tbz2 \
  && echo $PLEXAMP_BUILD_VERSION | sed -e 's/^v//' > /app/plexamp_version \
  && chown -R plexamp /app \
  && apt-get -y clean autoclean \
  && apt-get autoremove -y \
  && mv /usr/local/bin/node /usr/local/bin/node_pa # Make sure the process name is unique

# The buildroot lsof is important to make sure the host system can check what process is using the sound card
COPY --from=builder /busybox-1.35.0/_install/bin/busybox /bin/lsof
COPY docker/claimtoken /app/plexamp
COPY docker/start-plexamp /app/plexamp

VOLUME /home/plexamp
USER plexamp
WORKDIR /app/plexamp

CMD ["/bin/sh", "start-plexamp"]
#CMD ["sh", "-c", "sleep 3000" ]
