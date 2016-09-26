#!/bin/bash

# Usage compilePages.sh github_url devnet_url output_image_name

GITHUB_URL=$1
DEVNET_URL=$2
OUTPUT_IMAGE_NAME=$3
BREADCRUMB=$4

echo "Running compile script"
echo "Parameters:"
echo "GIT URL: $GITHUB_URL"
echo "DN URL: $DEVNET_URL"
echo "Breadcrumb: $BREADCRUMB"

# Generate HTML
#rm -Rf /docker-data/generated/*
#docker run --net=host -v /docker-data/generated:/home/generator/output nhsd/jekyllpublish sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB"

# Now, build an nginx container to serve up the pages
echo "WHOAMI?:"
whoami
mkdir nginx/site
cp -R /docker-data/generated/* nginx/site
docker build --no-cache -t $OUTPUT_IMAGE_NAME nginx/.
#rm -Rf /docker-data/generated/*
#rm -Rf ./nginx/site

