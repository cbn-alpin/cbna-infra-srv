#! /bin/bash
set -e

docker pull $IMAGE
docker stop $REPOSITORY || true
docker rm $REPOSITORY || true
docker run -d \
  --restart unless-stopped \
  --name $REPOSITORY \
  $IMAGE
