FROM ghcr.io/linuxserver/baseimage-debian:bullseye
# set version label
ARG BUILD_DATE
ARG VERSION

LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sweisgerber-dev"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
#
# Official Mopidy install for Debian/Ubuntu along with some extensions #################################################
#
RUN set -ex \
 && apt-get update \
 && apt-get install -y debian-archive-keyring \
 && apt-get install -y apt-transport-https \
 && apt-get install -y \
        curl \
        gnupg \
 && apt-get install -y \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-bad \
        python3 \
        python3-pip \
 && mkdir -p /etc/apt/keyrings/ \
 && curl -L https://apt.mopidy.com/mopidy.gpg -o /etc/apt/keyrings/mopidy-archive-keyring.gpg \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-get update \
 && apt-get install -y \
        mopidy \
        mopidy-mpd \
        mopidy-spotify \
 && pip install --no-cache-dir --upgrade pip wheel \
 && pip install --no-cache-dir --upgrade \
      Mopidy-Bandcamp \
      Mopidy-Iris \
      Mopidy-Jellyfin \
      Mopidy-Local \
      Mopidy-Podcast \
      Mopidy-Scrobbler \
      Mopidy-SomaFM \
      Mopidy-Subidy
# ^ Official Mopidy install for Debian/Ubuntu along with some extensions ^
#   (see https://docs.mopidy.com/en/latest/installation/debian/)
#
# copy defaults & s6-overlay stuff
COPY root/ /
# ports ###########################################################################################
# mopidy-http default port
EXPOSE 6680
# mpd plugin default port
EXPOSE 6600
# volumes #########################################################################################
VOLUME /config /music /data
