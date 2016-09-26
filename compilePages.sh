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
rm -Rf ./nginx/site
mkdir ./nginx/site
chmod 777 nginx/site
docker run --net=host -v "`pwd`/nginx/site":/tmp/site nhsd/jekyllpublish sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB"

# Now, build an nginx container to serve up the pages
docker build --no-cache -t $OUTPUT_IMAGE_NAME nginx/.
rm -Rf ./nginx/site

