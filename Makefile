DOCKER_REGISTRY = index.docker.io
IMAGE_NAME = ansible
IMAGE_VERSION = latest
IMAGE_ORG = flaccid
IMAGE_TAG = $(DOCKER_REGISTRY)/$(IMAGE_ORG)/$(IMAGE_NAME):$(IMAGE_VERSION)
KUBE_NAMESPACE = default

WORKING_DIR := $(shell pwd)

.DEFAULT_GOAL := help

.PHONY: build

docker-release:: docker-build docker-push ## Builds and pushes the docker image to the registry

docker-push:: ## Pushes the docker image to the registry
		@docker push $(IMAGE_TAG)

docker-build:: ## builds the docker image locally
		@docker build  \
			--pull \
			-t $(IMAGE_TAG) \
				$(WORKING_DIR)

docker-build-clean:: ## cleanly builds the docker image locally
		@docker build  \
			--no-cache \
			--pull \
			-t $(IMAGE_TAG) \
				$(WORKING_DIR)

docker-run:: ## Runs the docker image
		docker run \
			--name ansible \
			-it \
				$(IMAGE_TAG)

docker-exec-shell:: ## Executes a shell in running container
		@docker exec \
			-it \
				ansible /bin/bash

docker-run-shell:: ## Runs the docker image with bash as entrypoint
		@docker run \
			-it \
			--entrypoint /bin/bash \
				$(IMAGE_TAG)

docker-rm:: ## Removes the running docker container
		@docker rm -f ansible

docker-test:: ## tests the runtime of the docker image in a basic sense
		@docker run $(IMAGE_TAG) ansible --version

helm-install:: ## installs using helm from chart in repo
		@helm install \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
				ansible charts/ansible

helm-upgrade:: ## upgrades deployed helm release
		@helm upgrade \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
				ansible charts/ansible

helm-uninstall:: ## deletes and purges deployed helm release
		@helm uninstall \
			--namespace $(KUBE_NAMESPACE) \
				ansible

helm-reinstall:: helm-uninstall helm-install ## Uninstalls the helm release, then installs it again

helm-render:: ## prints out the rendered chart
		@helm install \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
			--dry-run \
			--debug \
				ansible charts/ansible

helm-validate:: ## runs a lint on the helm chart
		@helm lint \
			-f values.yaml \
			--namespace $(KUBE_NAMESPACE) \
				charts/ansible

helm-package:: ## packages the helm chart into an archive
		@helm package charts/ansible

helm-index:: ## creates/updates the helm repo index file
		@helm repo index --url https://flaccid.github.io/container-ansible/ .

helm-flush:: ## removes local helm packages and index file
		@rm -f ./pritunl-*.tgz
		@rm -f index.yaml

# A help target including self-documenting targets (see the awk statement)
define HELP_TEXT
Usage: make [TARGET]... [MAKEVAR1=SOMETHING]...

Available targets:
endef
export HELP_TEXT
help: ## This help target
	@cat .banner
	@echo
	@echo "$$HELP_TEXT"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / \
		{printf "\033[36m%-30s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)