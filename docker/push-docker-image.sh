#!/usr/bin/env bash

USAGE="Usage: $0 <AWS account> <AWS region> <base image (denvazh/gatling) version tag>"

export AWS_PROFILE=$1
export AWS_DEFAULT_REGION=$2
VERSION=$3

: ${AWS_PROFILE:?"Missing mandatory AWS profile. ${USAGE}"}
: ${AWS_DEFAULT_REGION:?"Missing mandatory AWS region. ${USAGE}"}
: ${VERSION:?"Missing mandatory version tag. ${USAGE}"}

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
DOCKER_IMAGE="${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/gatling-fargate"

docker build --build-arg GATLING_VERSION=${VERSION} -t ${DOCKER_IMAGE}:${VERSION} .

# AWS CLI 2 ECR login
aws ecr get-login-password \
    --region eu-west-1 \
    | docker login \
    --username AWS \
    --password-stdin ${ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com

echo "Push tagged image ${DOCKER_IMAGE}:${VERSION} to repository"
docker push "${DOCKER_IMAGE}:${VERSION}"
