#!/bin/bash

# Usage:
# buildCompiler.sh buildserverhostname

BUILD_HOST=$1

if [ -z $BUILD_HOST ]
then
  BUILD_HOST_PREFIX=""
else
  BUILD_HOST_PREFIX="--tlsverify -H $BUILD_HOST:2376"
fi


IMAGE_NAME=nhsd/jekyllpublish

# Build image
docker $BUILD_HOST_PREFIX build -t $IMAGE_NAME generate/.

