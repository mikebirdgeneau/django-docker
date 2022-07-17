SHELL=/bin/bash

# Include .env file and export variables for use as required:
#include .env
#export DJANGO_ENV

.DEFAULT_GOAL=help

build:    ## Build docker image with current app version
	docker -l debug build -f docker/Dockerfile . -t djangoapp:$$(git rev-parse --short HEAD);

test: build	## Run tests
	( \
	docker run --rm -v `pwd`/app:/site -v `pwd`/docker/main.cf:/etc/postfix/main.cf --env DJANGO_ENV=test --name djangotest djangoapp:$$(git rev-parse --short HEAD) -c 'python manage.py test --keepdb --parallel 4' \
	)

migrations: build	## Create migrations
	( \
	docker run --rm -v `pwd`/app:/site -v `pwd`/docker/main.cf:/etc/postfix/main.cf --env DJANGO_ENV=test --name djangotest djangoapp:$$(git rev-parse --short HEAD) -c 'python manage.py makemigrations' \
	)

migrate: build	## Migrate database
	( \
	TAG=$$(git rev-parse --short HEAD) docker-compose -f docker-compose.yml run --rm --entrypoint "python manage.py migrate" app \
	)

shell: build   ## Run shell within the current docker container:
	( \
	docker run --rm -v `pwd`/app:/app:z -it djangoapp:$$(git rev-parse --short HEAD) \
	)

run:  poetry build migrate ## Run the application using docker-compose
	( \
	TAG=$$(git rev-parse --short HEAD) docker-compose -f docker-compose.yml up \
	)

poetry:	build ## Update poetry dependencies
	docker -l debug build -f docker/Dockerfile . --target=pythonbuilder -t djangoapp_pythonbuilder:$$(git rev-parse --short HEAD);
	docker run --rm -v `pwd`/pyproject.toml:/app/pyproject.toml:z -v `pwd`/poetry.lock:/app/poetry.lock:z djangoapp_pythonbuilder:$$(git rev-parse --short HEAD) -c 'poetry update && poetry install --no-root'

all: poetry build test migrate run  ## Run all commands and start development server

PHONY: help all

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


