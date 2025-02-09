FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION
ARG MOPIDY_RELEASE

LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sweisgerber"
#
# Alpine Mopidy install along with some extensions #################################################
#
RUN set -ex \
  echo "**** setup apk testing mirror ****" \
  && echo "@testing https://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
  && cat /etc/apk/repositories \
  && echo "**** install runtime packages ****" \
  && apk add --no-cache -U --upgrade \
    alsa-utils \
    gst-plugins-good \
    gst-plugins-ugly \
    mopidy=~${MOPIDY_RELEASE} \
    py3-gobject3 \
    py3-mopidy-jellyfin@testing \
    py3-mopidy-local@testing \
    py3-mopidy-mpd@testing \
    py3-mopidy-spotify@testing \
    py3-mopidy-tidal@testing \
    py3-mopidy-youtube \
    py3-pip \
    python3 \
    sudo \
 && pip install --no-cache-dir --break-system-packages --upgrade pip wheel \
 && echo "**** install mopidy extensions ****" \
 && pip install --no-cache-dir --break-system-packages --upgrade \
      Mopidy-Bandcamp \
      Mopidy-Iris \
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
