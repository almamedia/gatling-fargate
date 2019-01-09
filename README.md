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
Build takes one build argument, which is GATLING_VERSION. NOTE: Gatling >= 3.0.0 is assumed, script command line arguments in run-gatling.sh are adjusted accordingly 

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

After the task definition has been posted, the gatling task can be run with [AWS CLI ecs run-task command](https://docs.aws.amazon.com/cli/latest/reference/ecs/run-task.html). Gatlings command line parameters can be overridden, as can the memory and cpu constraints to the task. This should be easy to script.

Commandline would look like this:

```
aws ecs run-task --cluster <your ecs cluster> --task-definition gatling-fargate --overrides <json>
```

The override JSON is a little bit verbose, it looks like following snippet. Unnecessary fields can be ommitted. Specifically, the field to override gatling parameters is containerOverrides.command. containerOverrides.name field is mandatory, The sole containedDEfinition inside the task definition is named gatling-fargate-container-def.

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
  --task-definition gatling-fargate \
  --overrides '{"containerOverrides":[ \
    { \
      "name": "gatling-fargate-container-def, \
      "command": ["--simulation", "Simulation class name>"] \
    } \
   ]}'
```

## Scaling out

It is possible to run the same simulation with multiple parallel Fargate tasks to achieve higher load.
 
Gatling is run with parameters --simulation className -nr -rf /opt/gatling/results/PREFIX with aws ecs run-task as described above but run-task is given additional --count parameter to launch multiple tasks at the same time

Example below runs 3 simultaneous instances of a simulation:

```
aws ecs run-task \
  --count 3 \
  --cluster <your ecs cluster> \
  --task-definition gatling-fargate \
  --overrides '{"containerOverrides":[ \
    { \
      "name": "gatling-fargate-container-def, \
      "command": ["--simulation", "className", "-nr", "-rf", "/opt/gatling/results/PREFIX"] \
    } \
   ]}'
```

After all tasks have finished, Gatling is run again with parameter -ro PREFIX to generate a combined result from logs that were saved in results/PREFIX folder in S3 bucket by the previous run-task:

```
aws ecs run-task \
  --cluster <your ecs cluster> \
  --task-definition gatling-fargate \
  --overrides '{"containerOverrides":[ \
    { \
      "name": "gatling-fargate-container-def, \
      "command": ["-ro", "PREFIX"] \
    } \
   ]}'
```

After this finishes, combined report is found in results/PREFIX dir in S3 bucket.

NOTE: tasks are not synchronized in any way, so they probably won't start at exactly the same second. This shouldn't matter too much as long as simulation length is measured in tens of seconds or minutes.

## Note about AWS policy regarding load testing

AWS needs to be warned beforehand when running potentially very load intensice tests. See https://aws.amazon.com/ec2/testing/ Failure to do this may have repercussions, you have been warned :)
