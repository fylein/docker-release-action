<h3 align="center">Docker Build and Push</h3>
<p align="center">Build docker images using Dockerfile in your repository and Push them to Docker Hub<p>


## Setup

This GitHub Action requires a bunch of environment variables, check the env section below.
  
```yaml
# .github/workflows/deploy.yml 
name: Build Code

on:
  push:
    branches:
      - master

jobs:
  assign:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - name: push to dockerhub
      uses: fylein/docker-release-action@master
      env:
        DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
        DOCKERHUB_PASSWORD: ${{ secrets.DOCKERHUB_PASSWORD }}
        IMAGE_NAME: ${{ secrets.IMAGE_NAME }}
```
