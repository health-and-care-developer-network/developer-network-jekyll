#!/bin/bash


# Check if image already exists
IMAGE_NAME=nhsd/jekyllpublish
IMAGE_ID=`docker $PREFIX inspect "$IMAGE_NAME" 2> /dev/null | grep Id | sed "s/\"//g" | sed "s/,//g" |  tr -s ' ' | cut -d ' ' -f3`
if [ -z "$IMAGE_ID" ]
then
  echo "Image doesn't exist"
else
  echo "Image exists - removing it"
  docker rm $IMAGE_NAME
fi

# Build image
docker build --no-cache -t $IMAGE_NAME generate/.

