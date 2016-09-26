#!/bin/bash

# Usage compilePages.sh github_url devnet_url output_container_name

GITHUB_URL=$1
DEVNET_URL=$2
OUTPUT_CONTAINER_NAME=$3

# Generate HTML
mkdir /tmp/site
chmod 777 /tmp/site
docker run --net=host -v /tmp/site:/output nhsd/jekyllpublish sh -c '/generate.sh GITHUB_URL DEVNET_URL'

# Now, build an nginx container to serve up the pages
mv /tmp/site nginx/site
docker build --no-cache -t $OUTPUT_CONTAINER_NAME nginx/.
rm -Rf nginx/site
