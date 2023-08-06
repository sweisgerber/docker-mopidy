FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION

LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sweisgerber"
#
# Alpine Mopidy install along with some extensions #################################################
#
RUN set -ex \
  echo "**** setup apk testing mirror ****" \
  && echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && cat /etc/apk/repositories \
  && echo "**** install runtime packages ****" \
  && apk add --no-cache -U --upgrade \
    alsa-utils \
    sudo \
    gst-plugins-good \
    gst-plugins-ugly \
    python3 \
    py3-pip \
    mopidy \
    py3-mopidy-local@testing \
    py3-mopidy-mpd@testing \
    py3-mopidy-spotify@testing \
 && pip install --no-cache-dir --break-system-packages --upgrade pip wheel \
 && echo "**** install mopidy extensions ****" \
 && pip install --no-cache-dir --break-system-packages --upgrade \
      Mopidy-Bandcamp \
      Mopidy-Iris \
      Mopidy-Jellyfin \
      Mopidy-Podcast \
      Mopidy-Scrobbler \
      Mopidy-SomaFM \
      Mopidy-Subidy \
  && echo "**** cleanup ****" \
  && rm -rf \
    /tmp/*
# copy defaults & s6-overlay stuff
COPY root/ /

# ports ###########################################################################################
# mopidy-http default port
EXPOSE 6680
# mpd plugin default port
EXPOSE 6600
# volumes #########################################################################################
VOLUME /config /music /data
