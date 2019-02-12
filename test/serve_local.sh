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

#!/usr/bin/env sh

source $(dirname $0)/common.sh

image=$1

docker run \
    -v ${CURRENT_DIR}/test/sagemaker_fs:/opt/ml \
    -p ${SAGEMAKER_HTTP_PORT}:${SAGEMAKER_HTTP_PORT} \
    --rm ${image} serve
