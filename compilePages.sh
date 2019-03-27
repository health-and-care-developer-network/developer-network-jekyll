#!/bin/bash

# Usage compilePages.sh registry_host target_host github_url devnet_url breadcrumb_name directory_name branch

REGISTRY_HOST=$1
TARGET_HOST=$2
GITHUB_URL=$3
DEVNET_URL=$4
BREADCRUMB=$5
DIR_NAME=$6
BRANCH=${7:-master}
BANNER_HTML_FILE=$8
VOLUME_PATH=${VOLUME_PATH:-/docker-data/jekyll-generated-pages}

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
  if [ ! -z $REGISTRY_HOST ]
  then
    # Explicitly pull the latest image from the repository so we know we are using the latest
    docker $TARGET_PREFIX pull $SOURCE_URL
  fi
fi

# Generate HTML
docker $TARGET_PREFIX rm jekyllpublish
docker $TARGET_PREFIX run \
	--add-host developer.nhs.uk:51.140.62.90 \
	--name jekyllpublish \
	-v $VOLUME_PATH:/content \
	$SOURCE_URL sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB $DIR_NAME $BRANCH $BANNER_HTML_FILE"
docker $TARGET_PREFIX rm jekyllpublish
