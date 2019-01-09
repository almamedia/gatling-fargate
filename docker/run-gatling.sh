#!/usr/bin/env bash

# Sync config, simulations and previous results (in case we want to combine results from previous runs) from s3

aws s3 sync s3://$WORK_BUCKET/user-files /opt/gatling/user-files
aws s3 sync s3://$WORK_BUCKET/conf /opt/gatling/conf
aws s3 sync s3://$WORK_BUCKET/results /opt/gatling/results

# Run gatling
export JAVA_OPTS="-Dsun.net.inetaddr.ttl=10 $JAVA_OPTS" && /opt/gatling/bin/gatling.sh -bf /opt/gatling/user-files/bin $@

# Sync report and logs to S3
aws s3 sync /opt/gatling/results s3://$WORK_BUCKET/results
# Sync compiled simulations to S3
aws s3 sync /opt/gatling/user-files s3://$WORK_BUCKET/user-files
