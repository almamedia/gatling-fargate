#!/usr/bin/env bash

USAGE="$0 <aws profile> <aws region> <gatling docker image name> <gatling version> <gatling bucket>"

export AWS_PROFILE=$1
export AWS_DEFAULT_REGION=$2
export GATLING_IMAGE=$3
export GATLING_VERSION=$4
export GATLING_BUCKET=$5

: ${AWS_PROFILE:?"Missing AWS profile, ${USAGE}"}
: ${AWS_DEFAULT_REGION?:"Missing AWS region, ${USAGE}"}
: ${GATLING_IMAGE:?"Missing gatling docker image name, ${USAGE}"}
: ${GATLING_VERSION:?"Missing gatling version, ${USAGE}"}
: ${GATLING_BUCKET:?"Missing gatling bucket, ${USAGE}"}


aws cloudformation validate-template \
    --template-body file://aws-ecs/cloudformation-ecs.yaml || exit 1

aws cloudformation deploy \
    --stack-name gatling-fargate \
    --template-file ./aws-ecs/cloudformation-ecs.yaml \
    --parameter-overrides "GatlingImage=${GATLING_IMAGE}" "GatlingVersion=${GATLING_VERSION}" "WorkBucket=${GATLING_BUCKET}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset || exit 1