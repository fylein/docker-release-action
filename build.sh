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

# Set up Docker Buildx for optimized builds
docker buildx create --use --driver docker-container --name multiarch --bootstrap 2>/dev/null || docker buildx use multiarch

docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD

echo "Building optimized Docker image with caching...";
if [ -n "$SENTRY_AUTH_TOKEN" ]; then
    docker buildx build \
        --platform linux/amd64 \
        --cache-from type=gha \
        --cache-to type=gha,mode=max \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --build-arg SENTRY_AUTH_TOKEN="$SENTRY_AUTH_TOKEN" \
        -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$NEW_TAG \
        --push .
else
    docker buildx build \
        --platform linux/amd64 \
        --cache-from type=gha \
        --cache-to type=gha,mode=max \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$NEW_TAG \
        --push .
fi

echo "NEW_TAG=v$(git rev-parse --short HEAD)" >> $GITHUB_ENV
echo "New tag: $NEW_TAG";
