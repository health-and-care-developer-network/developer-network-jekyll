#!/bin/bash

# Usage compilePages.sh registry_host github_url devnet_url breadcrumb_name directory_name

REGISTRY_HOST=$1
GITHUB_URL=$2
DEVNET_URL=$3
BREADCRUMB=$4
DIR_NAME=$5
VOLUME_PATH=${1:-/docker-data/jekyll-generated-pages}

REGISTRY_URL=$REGISTRY_HOST:5000

if [ -z $REGISTRY_HOST ]
then
  REGISTRY_HOST_PREFIX=""
else
  REGISTRY_HOST_PREFIX="--tlsverify -H $REGISTRY_HOST:2376"
fi

# Generate HTML
docker $REGISTRY_HOST_PREFIX run \
	-v $VOLUME_PATH:/content \
	nhsd/jekyllpublish sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB $DIR_NAME"


