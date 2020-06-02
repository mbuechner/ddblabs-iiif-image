# DDB2018: IIIF Image Server - A IIIF server for DNB images based on Cantaloupe
This is a Docker container with a configured [Cantaloupe](https://github.com/medusa-project/cantaloupe/) IIIF Image server. The server will download DNB image on-demand and deliver a precessed derivate. Note, that will take some time, so it's not a very fast service and for developing and testing only.

## Docker (Docker Hub registry)
Pull `iiif-image-dev` from [Docker Hub registry](https://hub.docker.com/r/ddblabs/iiif-image/):
```
docker pull ddblabs/iiif-image-dev
```
Start container:
```
docker run -p 80:80 iiif-image-dev
```
That's it!

## Docker (local)
This package is a [Docker](https://www.docker.com/) containter. To build the Docker containter run within the direcory with `Dockerfile` etc.
```
docker build -t iiif-image-dev .
```
Next step is to start the container. Jetty within the container will listen on port 80. If the containers outside port shall be 80 too, run:
```
docker run -p 80:80 -it iiif-image-dev iiif-image-dev
```
