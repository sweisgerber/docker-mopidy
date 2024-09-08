# Mopidy (Docker Image)

> Based on [linuxserver/docker-baseimage-alpine](https://github.com/linuxserver/docker-baseimage-alpine) & [mopidy/*](https://github.com/mopidy), as well as the [Iris Mopidy Client](https://github.com/jaedb/Iris).
>  Also available at [DockerHub](https://hub.docker.com/r/sweisgerber/mopidy

Should get used in conjunction with snapcast, as shown in https://github.com/sweisgerber/mopiroom.

## Features Include:

- Mopidy plugins
    - Mopidy-Bandcamp
    - Mopidy-Iris
    - Mopidy-Jellyfin
    - Mopidy-Podcast
    - Mopidy-Scrobbler
    - Mopidy-SomaFM
    - Mopidy-Subidy
- [Iris Mopidy Client](https://github.com/jaedb/Iris)
    - Iris can function as snapclient stream & manage snapserver
- FIFO usage to stream the audio from mopidy to snapcast
- Based on [linuxserver/docker-baseimage-alpine](https://github.com/linuxserver/docker-baseimage-alpine)
    - ... which allows use of [linuxserver/docker-mods](https://github.com/linuxserver/docker-mods/tree/universal-package-install) to add more pip & OS packages
    - Uses s6-overlay from base image
    - small footprint

## docker-compose

I strongly advice to use docker-compose, as using a docker commandline is quite annoying with a complex setup.
An example can get found [in the repository](./docker-compose.example.yml) which is mostly pre-configured, besides a few vars.

```yaml
version: "3"
services:
  mopidy:
    image: docker.io/sweisgerber/mopidy:alpine
    hostname: mopidy
    environment:
      - PUID=1000 # user ID which the mopidy service will run as, needs permissions to access the music
      - PGID=1000 # group ID which the mopidy service will run as, needs permissions to access the music
      - TZ=Europe/Berlin
      #
      # https://github.com/linuxserver/docker-mods/tree/universal-package-install
      #
      # Set alpine or pip package ENV vars for further mopidy extensions
      #
      - DOCKER_MODS=linuxserver/mods:universal-package-install
      - INSTALL_PIP_PACKAGES=Mopidy-Beets|Mopidy-dLeyna|Mopidy-InternetArchive|Mopidy-TuneIn|Mopidy-YTMusic
      # - INSTALL_PACKAGES=mopidy-podcast
    restart: "unless-stopped"
    ports:
      - 6600:6600 # Remote Control port for MPD
      - 6680:6680 # HTML API & Webinterface port for accessing mopidy
    # devices:
    # - /dev/snd:/dev/snd # optional, needed if you want to play to host audio devices.
    volumes:
      - $MOPIROOM_FOLDER/config/:/config/
      # contains mopidy configured FIFO location,
      # check mopidy.conf <https://github.com/sweisgerber/docker-mopidy/blob/main/root/defaults/mopidy.conf>
      # will get used by snapcast and streamed to the network.
      #
      # ```conf
      # [audio]
      # output = (...) location=/data/audio/snapcast_fifo
      # ```
      #
      # mopidy--FIFO-in-FileSystem-->SnapServer--LAN-Stream-->SnapClient
      #
      - $MOPIROOM_FOLDER/data/:/data/
      - $MOPIROOM_FOLDER/:/music/:ro # READ-ONLY & optional  (needed if you want to play audio files from host)
# One should use snapcast along mopidy/iris, use https://github.com/sweisgerber/docker-snapcast/blob/main/docker-compose.example.yml
```
