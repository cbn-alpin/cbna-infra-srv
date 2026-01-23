#! /bin/bash
set -e

# Pull the image
docker pull $IMAGE
# Restart the service to use the new image
docker compose up -d --no-deps $REPOSITORY || true
# Remove all unused and dangling (without tag) images
docker image prune -a -f
