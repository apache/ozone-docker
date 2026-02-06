# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG OZONE_RUNNER_IMAGE=apache/ozone-runner
ARG OZONE_RUNNER_VERSION=20260206-1-jdk21-slim
FROM ${OZONE_RUNNER_IMAGE}:${OZONE_RUNNER_VERSION}

ARG OZONE_VERSION=2.1.0
ARG OZONE_URL="https://www.apache.org/dyn/closer.lua?action=download&filename=ozone/${OZONE_VERSION}/ozone-${OZONE_VERSION}.tar.gz"

WORKDIR /opt
RUN sudo rm -rf /opt/hadoop && \
    curl -LSs -o ozone.tar.gz $OZONE_URL && \
    tar zxf ozone.tar.gz && \
    rm ozone.tar.gz && \
    mv ozone* hadoop && \
    cd hadoop && \
    sudo rm -rf \
        CONTRIBUTING.md \
        compose \
        docs \
        examples \
        HISTORY.md \
        kubernetes \
        README.md \
        SECURITY.md \
        share/ozone/byteman \
        share/ozone/lib/*-docs-*.jar \
        share/ozone/lib/ozone-filesystem-hadoop*.jar \
        smoketest \
        tests

WORKDIR /opt/hadoop

CMD ["echo","Please check https://github.com/apache/ozone-docker for information."]
