#!/bin/bash

# Usage deployLocal.sh image_name container_name port

IMAGE=$1
NAME=$2
PORT=$3

# Run container
docker run --name $NAME -d -p $PORT:80 $IMAGE

