MAINTAINER=mcgr0g
ASSEMBLY_NAME=docker-mopidy
IMG_NAME=$(MAINTAINER)/$(ASSEMBLY_NAME)
BUILD_DATE:=$(shell date '+%Y-%m-%d')
# VERSIONS ---------------------------------------------------------------------
# include .versions
# export
ASSEMBLY_VER=0.1.3
MOPIDY_VERSION=3.4.1
BUILD_ALPINE = Dockerfile
BUILD_DEBIAN = Dockerfile.debian
# BUILD FLAGS -----------------------------------------------------------------
B_BASE=docker build \
		--build-arg VERSION=$(ASSEMBLY_VER) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg assembly_name=$(ASSEMBLY_NAME) \
		--build-arg MOPIDY_RELEASE=$(MOPIDY_VERSION)
B_END=-t $(IMG_NAME):$(ASSEMBLY_VER)

B_SYS=-f $(BUILD_ALPINE)
# B_SYS=-f $(BUILD_DEBIAN)

BFLAGS=$(B_BASE) $(B_SYS) $(B_END)

BUILD_FAST=$(BFLAGS)   --progress=plain .
BUILD_FULL=$(BFLAGS)   --progress=plain --no-cache .
UPGRAGE_PKGS=$(BFLAGS) --build-arg UPGRADE=true .
UPDATE_PKGS=$(BFLAGS)  --progress=plain --build-arg UPDATE=true .
RECONF=$(BFLAGS)       --progress=plain --build-arg RECONFIGURED=true .

# IMAGE -----------------------------------------------------------------------

build:
	$(BUILD_FAST)
	
build-full:
	$(BUILD_FULL)

upgrade:
	$(UPGRAGE_PKGS)

update:
	$(UPDATE_PKGS)

reconf:
	$(RECONF)

weight:
	docker images $(IMG_NAME):$(ASSEMBLY_VER) \
	--format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}\t{{.Size}}"
	

weight-final:
	docker images \
	-f "label=org.opencontainers.image.title=$(ASSEMBLY_NAME)" \
	-f "label=org.opencontainers.image.version=$(ASSEMBLY_VER)" \
	--format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}\t{{.Size}}" \
	$(IMG_NAME):$(ASSEMBLY_VER)

weight-layered:
	docker history -H $(IMG_NAME):$(ASSEMBLY_VER)

login:
	docker login

prepush:
	docker tag $(IMG_NAME):$(ASSEMBLY_VER) $(IMG_NAME):latest

push:
	docker push $(IMG_NAME) --all-tags

pull:
	docker pull $(IMG_NAME)

# RUN FLAGS -------------------------------------------------------------------

CURR_PUID=$(shell id -u)
CURR_PGID=$(shell id -g)

RUNBASE=docker run --rm --name $(ASSEMBLY_NAME) \
		-e PUID=$(CURR_PUID) \
		-e PGID=$(CURR_PGID) \
		-e TZ=Europe/Moscow \
		-v ${PWD}/config:/config \
		-v "${PWD}/media:/music:ro" \
		-v ${PWD}/data:/data \
		-p 6680:6680 \
		-p 6600:6600

RUNEND=-t $(IMG_NAME):$(ASSEMBLY_VER)

RUN=$(RUNBASE) $(RUNEND)

# CONTAINER -------------------------------------------------------------------
volumes:
	- mkdir ${PWD}/data && mkdir ${PWD}/config

run:
	$(RUN)

flop:
	docker exec -it $(ASSEMBLY_NAME) /bin/bash

clear:
	rm -rf data/
	rm -rf config/
