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

FROM amazonlinux:2017.09

# Update packages and install Python prerequisites
RUN yum update -y
RUN yum -y install python36 python36-pip

# Install prerequisites for Datawig dependencies
RUN yum install -y gcc gcc-c++ python36-devel


# Install prerequisites for serving
RUN yum install -y nginx

# Install container specific packages for serving
RUN /usr/bin/pip-3.6 install flask gevent gunicorn

RUN /usr/bin/pip-3.6 install ipython

RUN yum install -y git

ARG datawig_version
RUN if [[ -n "$datawig_version" ]]; then /usr/bin/pip-3.6 install datawig==$datawig_version; else /usr/bin/pip-3.6 install datawig; fi

# PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly
ENV PYTHONUNBUFFERED=TRUE
# PYTHONDONTWRITEBYTECODE keeps Python from writing the .pyc files 
# which are unnecessary in this case
ENV PYTHONDONTWRITEBYTECODE=TRUE
# Also update PATH so that the train and serve programs are found
# when the container is invoked.
ENV PATH="/opt/program:${PATH}"

COPY imputation /opt/program
WORKDIR /opt/program
