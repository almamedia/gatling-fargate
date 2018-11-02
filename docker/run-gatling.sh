#!/usr/bin/env bash

# Sync config simulations and previous results (in case we want to combine results from previous runs) from s3

aws s3 sync s3://$WORK_BUCKET/user-files /opt/gatling/user-files
aws s3 sync s3://$WORK_BUCKET/conf /opt/gatling/conf
aws s3 sync s3://$WORK_BUCKET/results /opt/gatling/results

# Run gatling
/opt/gatling/bin/gatling.sh $@

# Sync report and logs to S3
aws s3 sync /opt/gatling/results s3://$WORK_BUCKET/results