#!/bin/bash

# Usage compilePages.sh registry_host target_host github_url devnet_url breadcrumb_name directory_name

REGISTRY_HOST=$1
TARGET_HOST=$2
GITHUB_URL=$3
DEVNET_URL=$4
BREADCRUMB=$5
DIR_NAME=$6
VOLUME_PATH=${1:-/docker-data/jekyll-generated-pages}

IMAGE_NAME=nhsd/jekyllpublish

REGISTRY_URL=$REGISTRY_HOST:5000

if [ -z $REGISTRY_HOST ]
then
  REGISTRY_HOST_PREFIX=""
  SOURCE_URL=$IMAGE_NAME
else
  REGISTRY_HOST_PREFIX="--tlsverify -H $REGISTRY_HOST:2376"
  SOURCE_URL=$REGISTRY_HOST:5000/$IMAGE_NAME
fi

if [ -z $TARGET_HOST ]
then
  TARGET_PREFIX=""
else
  TARGET_PREFIX="--tlsverify -H $TARGET_HOST:2376"
fi

# Generate HTML
docker $TARGET_PREFIX run \
	-v $VOLUME_PATH:/content \
	$SOURCE_URL sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB $DIR_NAME"


