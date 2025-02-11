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
    build-base \
    cairo \
    cairo-dev \
    dbus \
    dbus-dev \
    gobject-introspection \
    gobject-introspection-dev \
    gstreamer \
    gstreamer-dev \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-ugly \
    libxml2 \
    python3 \
    python3-dev \
    py3-pip \
    py3-virtualenv \
    sudo
RUN python3 -m venv /lsiopy \
 && pip install -U --no-cache-dir pip wheel setuptools \
 && echo "**** install mopidy extensions ****" \
 && pip install --no-cache-dir --upgrade \
    Mopidy-Bandcamp \
    Mopidy-Beets \
    Mopidy-InternetArchive \
    Mopidy-Iris \
    Mopidy-Jellyfin \
    Mopidy-Local \
    Mopidy-MPD \
    Mopidy-Podcast \
    Mopidy-Scrobbler \
    Mopidy-SomaFM \
    Mopidy-Subidy \
    Mopidy-Tidal \
    Mopidy-TuneIn \
    Mopidy-YTMusic \
    Mopidy==${MOPIDY_RELEASE} \
    PyGObject \
    dbus-python \
    pip \
    pycairo \
    pykka \
    requests \
    tornado \
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
