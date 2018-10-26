#! /bin/bash

USAGE="Usage: $0 <AWS account for ECR> <AWS region for ECR> <list of account (account ids) that need push/pull privileges>"

export AWS_PROFILE=$1
export AWS_DEFAULT_REGION=$2
export ECS_ACCOUNTS=$3

: ${AWS_PROFILE:?"Missing mandatory aws profile. ${USAGE}"}
: ${AWS_DEFAULT_REGION:?"Missing mandatory aws region. ${USAGE}"}
: ${ECS_ACCOUNTS:?"Missing mandatory list of associated aws account ids. ${USAGE}"}

STAKCNAME=gatling-fargate-ecr-repository

aws cloudformation deploy \
    --stack-name ${STAKCNAME} \
    --template-file ./cloudformation-ecr.yaml \
    --parameter-overrides "RepositoryName=gatling-fargate" "AllowedAccounts=${ECS_ACCOUNTS}" \
    --no-fail-on-empty-changeset