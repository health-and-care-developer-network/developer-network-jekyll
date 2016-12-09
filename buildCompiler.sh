#!/bin/bash

# Usage:
# buildCompiler.sh registry_hostname

REGISTRY_HOST=$1
IMAGE_NAME=nhsd/jekyllpublish

REGISTRY_URL=$REGISTRY_HOST:5000

if [ -z $REGISTRY_HOST ]
then
  REGISTRY_PREFIX=""
else
  REGISTRY_PREFIX="--tlsverify -H $REGISTRY_HOST:2376"
fi

# Build image
docker $REGISTRY_PREFIX build -t $IMAGE_NAME generate/.

# If we are using a private registry, push the image into it
if [ ! -z $REGISTRY_HOST ]
then
	docker $REGISTRY_PREFIX tag $IMAGE_NAME $REGISTRY_URL/$IMAGE_NAME
	docker $REGISTRY_PREFIX push $REGISTRY_URL/$IMAGE_NAME
	docker $REGISTRY_PREFIX rmi $IMAGE_NAME
fi
