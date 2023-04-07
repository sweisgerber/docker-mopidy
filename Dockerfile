FROM ghcr.io/linuxserver/baseimage-debian:bullseye
# set version label
ARG BUILD_DATE
ARG VERSION
ARG MOPIDY_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sweisgerber-dev"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && apt-get install -y debian-archive-keyring \
 && apt-get install -y apt-transport-https \
 && apt-get install -y \
        curl \
        gnupg

RUN set -ex \
  && apt-get install -y \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-bad \
        python3 \
        python3-pip

RUN set -ex \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

RUN set -ex \
 && mkdir -p /etc/apt/keyrings/ \
 && curl -L https://apt.mopidy.com/mopidy.gpg -o /etc/apt/keyrings/mopidy-archive-keyring.gpg \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-get update
RUN set -ex \
 && apt-get install -y \
        mopidy
RUN set -ex \
    pip install --no-cache-dir --upgrade pip wheel
RUN set -ex \
    pip install --no-cache-dir --upgrade \
      Mopidy-Autoplay \
      Mopidy-Iris \
      Mopidy-Local \
      Mopidy-MPD \
      Mopidy-SomaFM \
      Mopidy-Spotify

COPY root/ /

# ports and volumes
# mopidy-http default port
EXPOSE 6680
# mpd plugin default port
EXPOSE 6600

VOLUME /config /music
