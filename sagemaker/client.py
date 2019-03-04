#  Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License").
#  You may not use this file except in compliance with the License.
#  A copy of the License is located at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  or in the "license" file accompanying this file. This file is distributed
#  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
#  express or implied. See the License for the specific language governing
#  permissions and limitations under the License.

import json
import subprocess
from io import StringIO

import pandas as pd
import sagemaker

ALGORITHM_NAME = "datawig"
S3_BUCKET = "Specify S3 bucket here"
# if the script is used outside of SageMaker roles must be set,
# alternatively if the script is used from a SageMaker Notebook then sagemaker.get_execution_role() can be used to get the role
ROLE = "Specify the role here"


def build_and_push():
    args = ["./build_and_push.sh", ALGORITHM_NAME]
    subprocess.check_call(args)


def load_hps():
    with open('./test/sagemaker_fs/input/config/hyperparameters.json') as f:
        return json.load(f)


def upload_data(session):
    session = sagemaker.Session()
    print("Uploading a dataset for train to S3 ... ")
    data_location = session.upload_data("./test/sagemaker_fs/input/data/train/train.csv", bucket=S3_BUCKET, key_prefix="input")
    print("Done uploading.")

    return data_location


def train_model(session, data_location, hyperparameters):
    account = session.boto_session.client('sts').get_caller_identity()['Account']
    region = session.boto_session.region_name
    image = '{}.dkr.ecr.{}.amazonaws.com/{}:latest'.format(account, region, ALGORITHM_NAME)

    estimator = sagemaker.estimator.Estimator(image_name = image,
                                            role = ROLE,
                                            train_instance_count = 1,
                                            train_instance_type = 'ml.c4.2xlarge',
                                            output_path = "s3://{}/output".format(S3_BUCKET),
                                            sagemaker_session = session,
                                            hyperparameters = hyperparameters)

    print("Starting train procedure ...")
    estimator.fit(data_location)
    print("Training done.")

    return estimator


def impute(estimator):
    print("Deploying model ... ")
    imputer = estimator.deploy(initial_instance_count = 1,
                                instance_type = "ml.m4.xlarge",
                                serializer = sagemaker.predictor.csv_serializer)
    print("Deployment done.")

    pd_test = pd.read_csv("./test/test.csv", error_bad_lines=False, quoting=3)
    request = StringIO()
    pd_test.to_csv(request, index=False)

    print("Sending data for imputation ... ")
    response = imputer.predict(request.getvalue()).decode('utf-8')

    print("Response received.")
    
    s = StringIO(response)
    imputed = pd.read_csv(s, error_bad_lines=False, quoting=3)

    print(imputed)


if __name__ == "__main__":
    session = sagemaker.Session()

    build_and_push()
    data_location = upload_data(session)
    hps = load_hps()
    estimator = train_model(session, data_location, hps)
    impute(estimator)
