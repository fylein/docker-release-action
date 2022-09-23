#!/bin/bash
docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD
export NEW_TAG="v$(git rev-parse --short HEAD)";
docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$NEW_TAG .
echo "Pushing Docker Image to Docker Hub";
docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$NEW_TAG
echo "NEW_TAG=v$(git rev-parse --short HEAD)" >> $GITHUB_ENV
echo "New tag: $NEW_TAG";