# gatling-fargate
Run Gatling load testing tool as a task in Fargate.

Load simulations and gatling config from S3 bucket given in WORK_BUCKET environment variable. The bucket should have following directory structure

```
/user-files
/user-files/simulations
/user-files/data
/conf
```

Docker image is based on public [denvazh/gatling](https://hub.docker.com/r/denvazh/gatling/) image. Versioning is thought to follow base image's versioning.

Docker image's ENTRYPOINT is a light wrapper script around gatling.sh. Wrapper syncs simulations and config from S3 bucket, runs gatling with command line parameters given to the docker image and after gatling finishes, syncs results back to S3 bucket.

To inspect the results, configure the s3 bucket to act as a website and browse /results.

## Build Docker image

Build takes one build argument, which is GATLING_VERSION.

```
cd docker
docker build --build-arg GATLING_VERSION=<gatling version> -t <docker image name>:<tag>
```

## Run Docker image locally


You need AWS credentials with a default profile having full access to a S3 bucket containing your simulations and optional gatling config files.

 ```
 docker run -it -v ~/.aws:/root/.aws --env WORK_BUCKET=<s3 bucket containing gatling config and simulations> <docker image name>:<tag> --simulation <Name of your simulation class>
 ```

## Deploy a Fargate task

Build and push the Docker image to your favourite docker registry (ECR on the same AWS account you plan to run on, dockerhub, etc.)

Push script in docker subdir assumes that you have access to ECR repository named gatling-fargate and pushes there, you can then use that image to deploy as long as your Fargate cluster has access to repository.

Deploy ECS task definition:
```
cd deploy
./deploy.sh <aws profile> <aws region> <gatling-fargate docker image name> <gatling-fargate docker image tag> <gatling bucket>
```

## Run simulations in fargate

After the task definition has been posted, the gatling task can be run with [AWS CLI ecs run-task command](https://docs.aws.amazon.com/cli/latest/reference/ecs/run-task.html). Gatlings command line parameters can be overridden, as can the memory and cpu constraints to the task. This should be easy to script.

Commandline would look like this:

```
aws ecs run-task --cluster <your ecs cluster> --task-definition gatling-fargate --overrides <json>
```

The override JSON looks like following snippet, unnecessary fields are ommitted. Specifically, the field to override gatling parameters is containerOverrides.command

```
{
  "containerOverrides": [
    {
      "name": "string",
      "command": ["string", ...],
      "environment": [
        {
          "name": "string",
          "value": "string"
        }
        ...
      ],
      "cpu": integer,
      "memory": integer,
      "memoryReservation": integer
    }
    ...
  ],
  "taskRoleArn": "string",
  "executionRoleArn": "string"
}
```

### Example: Run single simulation

```
aws ecs run-task \
  --cluster <your ecs cluster> \
  --task-definition gatling-fargate 
  --overrides '{"containerOverrides":[ \
    { \
      "name": "gatling-fargate-conteiner-def, \
      "command": "--simulation <Simulation class name>" \
    } \
   ]}'
```

## Scaling out

It should be possible to run same simulation with multiple tasks running in parallel to achieve horizontal scaling of generated network load. The results can then be combined to a single report using gatling itself. This is very much WIP ATM.

## Note about AWS policy regarding load testing

AWS needs to be warned beforehand when running potentially very load intensice tests. See https://aws.amazon.com/ec2/testing/ Failure to do this may have repercussions, you have been warned :)
