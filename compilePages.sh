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
rm -Rf /tmp/site 
mkdir /tmp/site
chmod 777 /tmp/site
docker run --net=host -v /tmp/site:/output nhsd/jekyllpublish sh -c "/generate.sh $GITHUB_URL $DEVNET_URL $BREADCRUMB"

# Now, build an nginx container to serve up the pages
mv /tmp/site nginx/site
docker build --no-cache -t $OUTPUT_IMAGE_NAME nginx/.
#rm -Rf nginx/site

