# DataWig on SageMaker

[![GitHub license](https://img.shields.io/github/license/awslabs/datawig-sagemaker.svg)](https://github.com/awslabs/datawig-sagemaker/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/awslabs/datawig-sagemaker.svg)](https://github.com/awslabs/datawig-sagemaker/issues)
[![Build Status](https://travis-ci.org/awslabs/datawig-sagemaker.svg?branch=master)](https://travis-ci.org/awslabs/datawig-sagemaker)

This packages shows how to package __[DataWig][datawig]__ imputation algorithm for use with SageMaker. The code and structure of the package are heavily influenced by examples from the __[Amazon-SageMaker-Examples][asm]__ repository.

The following stack is used:

1. __[nginx][nginx]__ is a light-weight layer that handles the incoming HTTP requests and manages the I/O in and out of the container efficiently.
2. __[gunicorn][gunicorn]__ is a WSGI pre-forking worker server that runs multiple copies of the application and load balances between them.
3. __[flask][flask]__ is a simple web framework. It lets application to respond to call on the `/ping` and `/invocations` endpoints without having to write much code.

## The Structure of the Code

* __Dockerfile__.

* __build\_and\_push.sh__: The script to build the Docker image (using the Dockerfile above) and push it to the [Amazon EC2 Container Registry (ECR)][ecr] so that it can be deployed to SageMaker. Name of the image is used as the only argument to this script. The script will generate a full name for the repository in AWS account account and configured AWS region. If this ECR repository doesn't exist, the script will create it.
  * As part of this script you can set the desired DataWig version to be installed inside the Docker image. Check our [PyPI repository][pypi] for the latest version.

* __imputation__: The directory that contains the application to run in the container.

* __test__: The directory that contains scripts and a setup for running a simple training and inference jobs locally.

* __sagemaker__: The directory that contains an example of client code to setup an endpoint with imputation model in SageMaker.

### The application run inside the container

This container is set up so that the argument in treated as the command that the container executes. When training, it will run the __train__ program included and, when serving, it will run the __serve__ program.

* __train__: The main program for training the model.
* __serve__: The wrapper that starts the inference server. 
* __wsgi.py__: The start up shell for the individual server workers.
* __imputer.py__: The algorithm-specific imputation server. 
* __nginx.conf__: The configuration for the nginx master server that manages the multiple workers.

### Setup for local testing

The subdirectory 'test' contains scripts and sample data for testing the built container image on the local machine. 

* __common.sh__: Stores shared variables across test scripts.
* __train_local.sh__: Instantiate the container configured for training.
* __serve_local.sh__: Instantiate the container configured for serving.
* __impute.sh__: Run predictions against a locally instantiated server.
* __sagemaker_fs__: The directory that gets mounted into the container with test data mounted in all the places that match the container schema.
* __test.csv__: Sample data for used by impute.sh for testing the server.

```bash
 ./test/train_local.sh $IMAGE_NAME 
 ./test/serve_local.sh $IMAGE_NAME 
 ./test/impute.sh ./test/test.csv
```

The training and test data is a subsample of the IMDb data that was introduced by Maas et al. in [Learning Word Vectors for Sentiment Analysis][imdb].

#### The directory tree mounted into the container

The tree under test-dir is mounted into the container and mimics the directory structure that SageMaker would create for the running container during training or hosting.

* __input/config/hyperparameters.json__: The hyperparameters for the training job.
* __input/data/training/train.csv__: The training data.
* __model__: The directory where the algorithm writes the model file.
* __output__: The directory where the algorithm can write its success or failure file.

### Client code example 

* __client.py__:  Code example to train imputation model and host it in SageMaker. `ALGORITHM_NAME`, `S3_BUCKET` and `ROLE` parameters must be updated before running the script 
* __reqirements.txt__: Required dependencies for client code to run

```bash
 pip3 install -r sagemaker/requirements.txt
 python3 sagemaker/client.py
```

## Environment variables

When you create an imputation server, you can control some of Gunicorn's options via environment variables. These
can be supplied as part of the CreateModel API call.

    Parameter                Environment Variable              Default Value
    ---------                --------------------              -------------
    number of workers        MODEL_SERVER_WORKERS              the number of CPU cores
    timeout                  MODEL_SERVER_TIMEOUT              60 seconds


## License

This library is licensed under the Apache 2.0 License. 


[ecr]: https://aws.amazon.com/ecr/ "ECR Home Page"
[nginx]: http://nginx.org/
[gunicorn]: http://gunicorn.org/
[flask]: http://flask.pocoo.org/
[datawig]: https://github.com/awslabs/datawig
[asm]: https://github.com/awslabs/amazon-sagemaker-examples/tree/master/advanced_functionality
[imdb]: https://dl.acm.org/citation.cfm?id=2002491
[pypi]: https://pypi.org/project/datawig
