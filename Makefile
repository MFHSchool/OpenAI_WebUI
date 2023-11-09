SHELL := /bin/bash
.PHONY: all

# Decide which "no-cache" policy you want for your builds
#OAI_NOCACHE="--no-cache"
OAI_NOCACHE=

# Base python image base on Debian
OAI_BASE="python:3.12-slim-bookworm"

# Version infomation and container name
OAI_VERSION="0.9.0"
OAI_CONTAINER_NAME="openai_webui"

# Default build tag
OAI_BUILD="${OAI_CONTAINER_NAME}:${OAI_VERSION}"
OAI_BUILD_LATEST="${OAI_CONTAINER_NAME}:latest"

# Unraid build tag
OAI_UNRAID_BUILD="${OAI_CONTAINER_NAME}-unraid:${OAI_VERSION}"
OAI_UNRAID_BUILD_LATEST="${OAI_CONTAINER_NAME}-unraid:latest"

all:
	@echo "** Available Docker images to be built (make targets):"
	@echo "build:          will build both latest and unraid images"
	@echo "  build_main:   will build the ${OAI_BUILD} image and tag it as latest as well"
	@echo "  build_unraid: will build the ${OAI_UNRAID_BUILD} image and tag it as latest as well"
	@echo ""
	@echo "delete_images:   will delete the main and unraid images"
	@echo "  delete_unraid: will delete the unraid images (has to be done before you can delete the other)"
	@echo "  delete_main:   will delete the main latest images"

build_main:
	docker build --build-arg OAI_BASE=${OAI_BASE} ${OAI_NOCACHE} -t ${OAI_BUILD} -f Dockerfile .
	docker tag ${OAI_BUILD} ${OAI_BUILD_LATEST}

build_unraid:
	docker build --build-arg OAI_BUILD=${OAI_BUILD} ${OAI_NOCACHE} -t ${OAI_UNRAID_BUILD} -f unraid/Dockerfile .
	docker tag ${OAI_UNRAID_BUILD} ${OAI_UNRAID_BUILD_LATEST}

build:
	@make build_main
	@make build_unraid

delete_unraid:
	@docker rmi ${OAI_UNRAID_BUILD_LATEST}
	@docker rmi ${OAI_UNRAID_BUILD}

delete_main:
	@docker rmi ${OAI_BUILD_LATEST}
	@docker rmi ${OAI_BUILD}

delete_images:
	@make delete_unraid
	@make delete_main

##

docker_push:
	@make build_main
	@docker tag ${OAI_BUILD_LATEST} infotrend/${OAI_BUILD_LATEST}
	@make build_unraid
	@docker tag ${OAI_UNRAID_BUILD_LATEST} infotrend/${OAI_UNRAID_BUILD_LATEST}
	@echo docker push infotrend/${OAI_BUILD_LATEST}
	@echo docker push infotrend/${OAI_UNRAID_BUILD_LATEST}