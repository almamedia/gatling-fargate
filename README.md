# gatling-fargate
Run Gatling load testing tool as a task in Fargate.

Load simulations and gatling config from S3 bucket given in WORK_BUCKET environment variable. The bucket should have following directory structure

```
/user-files
/user-files/simulations
/user-files/data
/conf
```

Docker image is based on public denvazh/gatling image. Versioning is thought to follow base image's versioning.

Docker image's ENTRYPOINT is a light wrapper script around gatling.sh. Wrapper syncs simulations and config from S3 bucket, runs gatling with command line parameters given to the docker image and after gatling finishes, syncs results back to S3 bucket.

To inspect the results, configure the s3 bucket to act as a website and browse /results.

Build Docker image
===
Build takes one build argument, which is GATLING_VERSION.

```
cd docker
docker build --build-arg GATLING_VERSION=<gatling version> -t <docker image name>:<tag>
```

Run Docker image locally
===

You need AWS credentials with a default profile having full access to a S3 bucket containing your simulations and optional gatling config files.

 ```
 docker run -it -v ~/.aws:/root/.aws --env WORK_BUCKET=<s3 bucket containing gatling config and simulations> <docker image name>:<tag> --simulation <Name of your simulation class>
 ```

Deploy as a fargate task
===
Build and push the Docker image to your favourite docker registry (ECR on the same AWS account you plan to run on, dockerhub, etc.)

Push script in docker subdir assumes that you have access to ECR repository named gatling-fargate and pushes there, you can then use that image to deploy as long as your Fargate cluster has access to repository.

Deploy ECS task definition:
```
cd deploy
./deploy.sh <aws profile> <aws region> <gatling-fargate docker image name> <gatling-fargate docker image tag> <gatling bucket>
```

Run simulations in fargate
===

Work In Progress
