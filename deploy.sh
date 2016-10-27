#!/bin/bash

# Usage:
# deploy.sh registry_hostname target_hostname image_name container_name port

REGISTRY_HOST=$1
TARGET_HOST=$2
IMAGE=$3
NAME=$4
PORT=$5

REGISTRY_URL=$REGISTRY_HOST:5000

if [ -z $REGISTRY_HOST ]
then
  REGISTRY_PREFIX=""
else
  REGISTRY_PREFIX="--tlsverify -H $REGISTRY_HOST:2376"
fi

if [ -z $TARGET_HOST ]
then
  TARGET_PREFIX=""
else
  TARGET_PREFIX="--tlsverify -H $TARGET_HOST:2376"
fi

IMAGE_IN_REGISTRY=$REGISTRY_URL/$IMAGE

# Run container
docker $TARGET_PREFIX stop $NAME
docker $TARGET_PREFIX rm $NAME
docker $TARGET_PREFIX run --name $NAME -d -p $PORT:80 $IMAGE_IN_REGISTRY

