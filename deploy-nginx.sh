#!/bin/bash

# Usage:
# deploy-nginx.sh volumepath registryhostname targethostname

VOLUME_PATH=${1:-/docker-data/jekyll-generated-pages}
REGISTRY_HOST=$2
TARGET_HOST=$3

LISTEN_PORT=${LISTEN_PORT:-8081}
CONTAINER_NAME=${CONTAINER_NAME:-nginx-jekyll}
IMAGE_NAME=${IMAGE_NAME:-nginx:1.10-alpine}

if [ -z $TARGET_HOST ]
then
  TARGET_PREFIX=""
else
  TARGET_PREFIX="--tlsverify -H $TARGET_HOST:2376"
fi

if [ -z $REGISTRY_HOST ]
then
  # No private docker registry
  REGISTRY_PREFIX=""
  SOURCE_URL=$IMAGE_NAME
else
  # Registry specified, so use it
  REGISTRY_PREFIX="--tlsverify -H $REGISTRY_HOST:2376"
  SOURCE_URL=$REGISTRY_HOST:5000/$IMAGE_NAME

  echo "Ensure the image is in our registry, and if not add it"
  ./populateImageIntoRegistry.sh $IMAGE_NAME $REGISTRY_HOST
fi

MEMORYFLAG=500m
CPUFLAG=768

echo "Pull and run nginx"
docker $TARGET_PREFIX stop $CONTAINER_NAME
docker $TARGET_PREFIX rm $CONTAINER_NAME
docker $TARGET_PREFIX run --name $CONTAINER_NAME \
	--restart=on-failure:5 \
	-u 1000 \
        -m $MEMORYFLAG \
	-c $CPUFLAG \
	-v $VOLUME_PATH:/usr/share/nginx/html \
	-p $LISTEN_PORT:80 \
	-d $SOURCE_URL

