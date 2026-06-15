#!/usr/bin/env bash
# Builds the Lambda container image. CI
# (.github/workflows/build-deploy-lambda.yml) runs this; you can run it locally
# too. Passes the Ruby version from .tool-versions so the image matches your
# toolchain.

docker buildx build $DOCKER_ARGS \
  --build-arg RUBY_VERSION=$(grep ruby .tool-versions | awk '{ print $NF }' | cut -d'.' -f1-2) \
  .
