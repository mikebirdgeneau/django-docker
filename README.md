# Python Django Docker Deployment

This repository is a simple example of a Python Django Docker deployment:

- Dockerfile contains multistage build to create an image with python3 and Django.
- docker-compose.yml image included to create a deployment with a database and a web server.
- Small example app is included, and should be replaced with the actual django application.
- Python packages are managed with poetry

## Usage

This repository contains a simple (mostly empty) django app.
You should be able to remove the `app` subfolder and replace it with your own django app.

Once you have your app, you can run the following command to run it:

```bash 
make all
```
The `Makefile` also contains several other commands to help facilitate managing your app. 
To see these, type `make help`, or open the Makefile!

