#!/bin/bash

# Fail fast
set -e

branch_name=$(git branch --show-current)

if [[ "$branch_name" == *release* ]]; then
    git fetch --tags
    last_release_version=$(git tag --sort=-version:refname | grep ${branch_name} | head -n 1)

    # if no release tag present, it means branch_name is newly created, so create first version
    if [[ "$last_release_version" == "" ]]; then
        NEW_TAG="${branch_name}_0"
    else
        current_patch_identifier=$(echo $last_release_version | awk -F _ '{print $NF}')
        new_patch_identifier=$((current_patch_identifier + 1))
        NEW_TAG="${branch_name}_${new_patch_identifier}"
    fi

    git config --global user.email "integrations@fylehq.com"
    git config --global user.name "GitHub Actions"
    git tag -a "${NEW_TAG}" -m "automatically tagged ${NEW_TAG}"
    git push origin "${NEW_TAG}"
else
    NEW_TAG="v$(git rev-parse --short HEAD)"
fi
echo "new_tag=$NEW_TAG" >> $GITHUB_OUTPUT

docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD

if [ -z "$DOCKERFILE" ]; then
    DOCKERFILE="Dockerfile"
fi

if [ -n "$SENTRY_AUTH_TOKEN" ]; then
    docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$NEW_TAG -f $DOCKERFILE --build-arg SENTRY_AUTH_TOKEN="$SENTRY_AUTH_TOKEN" .
else
    docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$NEW_TAG -f $DOCKERFILE .
fi

echo "Pushing Docker Image to Docker Hub";
docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$NEW_TAG
echo "NEW_TAG=v$(git rev-parse --short HEAD)" >> $GITHUB_ENV
echo "New tag: $NEW_TAG";
