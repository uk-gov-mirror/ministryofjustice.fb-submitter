#!/usr/bin/env bash
# exit as soon as any command fails
set -e

REPO_SCOPE=${REPO_SCOPE:-aldavidson}

for TYPE in base api worker
do
  REPO_NAME=${REPO_SCOPE}/fb-submitter-${TYPE}
  echo "Building ${REPO_NAME}"
  docker build -f docker/${TYPE}/Dockerfile -t ${REPO_NAME} .
  echo "Pushing ${REPO_NAME} to dockerhub"
  docker push ${REPO_NAME}
done
