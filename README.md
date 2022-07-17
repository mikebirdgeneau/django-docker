# Python Django Docker Deployment
![GitHub](https://img.shields.io/github/license/mikebirdgeneau/django-docker?color=blue)
![Python Version](https://img.shields.io/static/v1?label=python&message=v3.10&color=3776AB&logo=python)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/mikebirdgeneau/django-docker/makefile?logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/mikebirdgeneau/django-docker)
![GitHub issues](https://img.shields.io/github/issues/mikebirdgeneau/django-docker)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/mikebirdgeneau/django-docker)
![GitHub Release Date](https://img.shields.io/github/release-date/mikebirdgeneau/django-docker)

This repository contains a template for development of Django applications within Docker containers.

## Overview

This repository contains a simple (somewhat minimal) example of a Django application contained within docker containers; this allows for the development environment to mirror the deployment environment. Ideally we follow the [12 Factor App](https://12factor.net/) principles as closely as possible...

Features include:
- Minimal django app (which should be replaced with your app).
- Dockerfile with multistage build, that generates the application environment, including python packages which are managed using Poetry.
- Docker-Compose used for deployment of app, as well as required services (e.g. PostgreSQL, Redis).
- Makefile configured to run common tasks within the Docker / Docker-compose environments.

Other features that should be added:
- Celery (for task queues)
- Improvement on use of enviroment variables for deployments to different environments (e.g. dev / staging / production).
- Include some Django best-practices (or at least things I find handy, like split-settings).
- Implementation of additional tests.
- Use docker-slim to slim down the final producito image.

Feedback & improvements welcome!

## Usage

This repository contains a simple (mostly empty) django app.
You should be able to remove the `app` subfolder and replace it with your own django app.

Once you have your app, you can run the following command to run it:

```bash 
make all
```
The `Makefile` also contains several other commands to help facilitate managing your app. 
To see these, type `make help`, or open the Makefile!

