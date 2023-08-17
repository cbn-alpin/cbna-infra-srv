#! /bin/bash
set -e

docker pull $IMAGE
docker compose up -d --no-deps $REPOSITORY || true
