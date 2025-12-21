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
ARG OZONE_RUNNER_VERSION=20250410-1-jdk21
FROM ${OZONE_RUNNER_IMAGE}:${OZONE_RUNNER_VERSION}

ARG OZONE_VERSION=2.0.0
ARG OZONE_URL="https://www.apache.org/dyn/closer.lua?action=download&filename=ozone/${OZONE_VERSION}/ozone-${OZONE_VERSION}.tar.gz"

WORKDIR /opt
RUN sudo rm -rf /opt/hadoop && curl -LSs -o ozone.tar.gz $OZONE_URL && tar zxf ozone.tar.gz && rm ozone.tar.gz && mv ozone* hadoop

WORKDIR /opt/hadoop

# Remove unnecessary files to reduce image size (HDDS-13426)
RUN sudo find . -type f \( \
        -name "ozone-filesystem-hadoop2-*.jar" -o \
        -name "ozone-filesystem-hadoop3-*.jar" -o \
        -name "ozone-filesystem-hadoop3-client-*.jar" -o \
        -name "*-tests.jar" -o \
        -name "*-test.jar" -o \
        -name "*test*.jar" -o \
        -name "*-docs-*.jar" -o \
        -name "*-shaded.jar" -o \
        -name "*-all.jar" -o \
        -name "*-fat.jar" -o \
        -name "*.class" -o \
        -name "*.pyc" -o \
        -name ".DS_Store" \
    \) -delete 2>/dev/null || true && \
    # Remove documentation, examples, and license files
    sudo rm -rf docs examples share/doc share/man licenses \
        LICENSE.txt NOTICE.txt README.md HISTORY.md SECURITY.md CONTRIBUTING.md \
        compose kubernetes/examples share/ozone/byteman 2>/dev/null || true && \
    # Remove all markdown and text documentation files
    sudo find . -type f \( -name "*.md" -o -name "*.txt" \) ! -path "*/etc/*" ! -path "*/bin/*" ! -path "*/sbin/*" ! -path "*/libexec/*" -delete 2>/dev/null || true && \
    # Remove test directories
    sudo find . -type d \( -name "test*" -o -name "tests" -o -name "*test" \) -exec rm -rf {} + 2>/dev/null || true && \
    # Remove empty directories
    sudo find . -type d -empty -delete 2>/dev/null || true

CMD ["echo","Please check https://github.com/apache/ozone-docker for information."]
