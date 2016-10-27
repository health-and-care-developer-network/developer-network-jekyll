#!/bin/bash

# Usage compilePages.sh registry_host github_url devnet_url output_image_name breadcrumb_name context_path

REGISTRY_HOST=$1
GITHUB_URL=$2
DEVNET_URL=$3
OUTPUT_IMAGE_NAME=$4
BREADCRUMB=$5
CONTEXT_PATH=$6

REGISTRY_URL=$REGISTRY_HOST:5000

if [ -z $REGISTRY_HOST ]
then
  REGISTRY_HOST_PREFIX=""
else
  REGISTRY_HOST_PREFIX="--tlsverify -H $REGISTRY_HOST:2376"
fi

# Generate HTML
docker $REGISTRY_HOST_PREFIX run --net=host -v /docker-data/jenkins_home/generated:/home/generator/output nhsd/jekyllpublish sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB"

# Copy the generated content into a path we can use from the nginx dockerfile
mkdir -p nginx/site/$CONTEXT_PATH
cp -R /var/jenkins_home/generated/* nginx/site/$CONTEXT_PATH

# Now, build an nginx container to serve up the pages
docker $REGISTRY_HOST_PREFIX build --no-cache -t $OUTPUT_IMAGE_NAME nginx/.
docker $REGISTRY_HOST_PREFIX tag $OUTPUT_IMAGE_NAME $REGISTRY_URL/$OUTPUT_IMAGE_NAME
docker $REGISTRY_HOST_PREFIX push $REGISTRY_URL/$OUTPUT_IMAGE_NAME
docker $REGISTRY_HOST_PREFIX rmi $OUTPUT_IMAGE_NAME

# Clean up
rm -Rf /var/jenkins_home/generated/*
rm -Rf ./nginx/site

