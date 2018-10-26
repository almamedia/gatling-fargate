# gatling-fargate
Run Gatling load testing tool as a task in Fargate.

Load simulations and gatling config from S3 bucket given in WORK_BUCKET environment variable. The bucket should have following directory structure

```
/user-files
/user-files/simulations
/user-files/data
/conf
```

Docker image's ENTRYPOINT is a light wrapper script around gatling itself that syncs simulations and config from S3 bucket, runs gatling with command line parameters given to the docker image and after gatling finishes, syncs results back to S3 bucket. 

To see the results, configure the s3 bucket to act as a website and browse /results.

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

Push script in docker subdir assumes that you have ECR repository named gatling-fargate and pushes there, you can then use image name pointing there in deploy.

Deploy ECS task definition:
```
cd deploy
./deploy.sh <aws profile> <aws region> <gatling-fargate docker image name> <gatling-fargate docker image tag> <gatling bucket>
```

Run simulations in fargate
===

Work In Progress
