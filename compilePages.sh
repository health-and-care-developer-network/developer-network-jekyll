#!/bin/bash

# Usage compilePages.sh github_url devnet_url output_image_name context_path

GITHUB_URL=$1
DEVNET_URL=$2
OUTPUT_IMAGE_NAME=$3
BREADCRUMB=$4
CONTEXT_PATH=$5

# Generate HTML
docker run --net=host -v /docker-data/generated:/home/generator/output nhsd/jekyllpublish sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB"

# Now, build an nginx container to serve up the pages
mkdir -p nginx/site/$CONTEXT_PATH
cp -R /docker-data/generated/* nginx/site/$CONTEXT_PATH
docker build --no-cache -t $OUTPUT_IMAGE_NAME nginx/.
rm -Rf /docker-data/generated/*
rm -Rf ./nginx/site

