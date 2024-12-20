# Stage 1: Build busybox with lsof
FROM node:20-bookworm-slim 

ARG PLEXAMP_BUILD_VERSION=4.11.4
RUN apt -y update \
  && apt -y upgrade \
  && apt -y install --no-install-recommends bzip2 alsa-utils liblo-dev jq curl ca-certificates expect pipewire-alsa \
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

COPY docker/claimtoken /app/plexamp
COPY docker/start-plexamp /app/plexamp

VOLUME /home/plexamp
USER plexamp
WORKDIR /app/plexamp

CMD ["/bin/sh", "start-plexamp"]
#CMD ["sh", "-c", "sleep 3000" ]
