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

ARG OZONE_VERSION=2.1.1
ARG OZONE_IMAGE=apache/ozone
ARG OZONE_IMAGE_VERSION=${OZONE_VERSION}-slim

FROM ${OZONE_IMAGE}:${OZONE_IMAGE_VERSION}

ENV OZONE_CONF_DIR=/etc/hadoop \
    OZONE_LOG_DIR=/var/log/hadoop \
    no_proxy=localhost,127.0.0.1

USER root

# Install pre-baked Ozone configuration and create data/log dirs owned by hadoop.
COPY conf/core-site.xml conf/ozone-site.xml /etc/hadoop/
RUN mkdir -p /data/metadata /data/hdds /var/log/hadoop \
    && chown -R hadoop:hadoop /data /var/log/hadoop \
    && chmod -R 755 /data

# Only S3 Gateway and Recon are user-facing in the quickstart.
EXPOSE 9878 9888

VOLUME ["/data/metadata", "/data/hdds", "/var/log/hadoop"]

COPY --chmod=755 start-all-services.sh /usr/local/bin/start-all-services.sh

USER hadoop

CMD ["/usr/local/bin/start-all-services.sh"]
