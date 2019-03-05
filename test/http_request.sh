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

set -e

while [ `docker ps -q | wc -l` -lt 1 ]
do
    echo "Waiting for SageMaker server to start"
    sleep 1
done

curl -v http://localhost:${SAGEMAKER_HTTP_PORT}/ping

curl -v localhost:${SAGEMAKER_HTTP_PORT}/invocations -XPOST -H 'Content-Type: application/json' -d '{"instances": [{"review": "awesome movie i really liked it alot"}]}' | jq
