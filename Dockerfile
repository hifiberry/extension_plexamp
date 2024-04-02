FROM node:16-bullseye-slim 

ARG PLEXAMP_BUILD_VERSION=4.10.1
RUN apt -y update \
  && apt -y upgrade \
  && apt -y install --no-install-recommends bzip2 alsa-utils \
  && apt -y install --no-install-recommends liblo-dev jq curl ca-certificates

RUN groupadd -g 2000 plexamp \
  && useradd -g 2000 -u 2002 -s /bin/bash -d /home/plexamp -G audio plexamp


RUN mkdir /app && \
  curl -o /tmp/plexamp-linux.tbz2 -L https://plexamp.plex.tv/headless/Plexamp-Linux-headless-v${PLEXAMP_BUILD_VERSION}.tar.bz2 && \
  tar -jxvf /tmp/plexamp-linux.tbz2 -C /app && \
  rm -f /tmp/*.tbz2 && \
  echo $PLEXAMP_BUILD_VERSION | sed -e 's/^v//' > /app/plexamp_version  && \
  chown -R plexamp /app && \
  apt-get -y clean autoclean && \
  apt-get autoremove -y 

VOLUME /home/plexamp
USER plexamp
WORKDIR /app/plexamp

CMD ["node", "js/index.js"]
