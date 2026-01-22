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

ARG OZONE_VERSION=2.1.0
ARG OZONE_RUNNER_IMAGE=apache/ozone
ARG OZONE_RUNNER_VERSION=${OZONE_VERSION}-slim

FROM ${OZONE_RUNNER_IMAGE}:${OZONE_RUNNER_VERSION}

# Environment variables for Ozone configuration
ENV CORE-SITE.XML_fs.defaultFS=ofs://localhost \
    CORE-SITE.XML_fs.trash.interval=1 \
    CORE-SITE.XML_hadoop.proxyuser.hadoop.hosts=* \
    CORE-SITE.XML_hadoop.proxyuser.hadoop.groups=* \
    OZONE-SITE.XML_ozone.om.address=localhost \
    OZONE-SITE.XML_ozone.om.http-address=localhost:9874 \
    OZONE-SITE.XML_ozone.scm.http-address=localhost:9876 \
    OZONE-SITE.XML_ozone.scm.container.size=1GB \
    OZONE-SITE.XML_ozone.scm.block.size=1MB \
    OZONE-SITE.XML_ozone.scm.datanode.ratis.volume.free-space.min=10MB \
    OZONE-SITE.XML_ozone.scm.pipeline.creation.interval=5s \
    OZONE-SITE.XML_ozone.scm.pipeline.owner.container.count=1 \
    OZONE-SITE.XML_ozone.scm.ec.pipeline.minimum=1 \
    OZONE-SITE.XML_ozone.scm.names=localhost \
    OZONE-SITE.XML_ozone.scm.datanode.id.dir=/data/metadata \
    OZONE-SITE.XML_ozone.scm.block.client.address=localhost \
    OZONE-SITE.XML_ozone.metadata.dirs=/data/metadata \
    OZONE-SITE.XML_ozone.recon.db.dir=/data/metadata/recon \
    OZONE-SITE.XML_ozone.scm.client.address=localhost \
    OZONE-SITE.XML_hdds.datanode.dir=/data/hdds \
    OZONE-SITE.XML_hdds.datanode.volume.min.free.space=100MB \
    OZONE-SITE.XML_hdds.datanode.volume.min.free.space.percent=0 \
    OZONE-SITE.XML_ozone.recon.address=localhost:9891 \
    OZONE-SITE.XML_ozone.recon.http-address=0.0.0.0:9888 \
    OZONE-SITE.XML_ozone.recon.https-address=0.0.0.0:9889 \
    OZONE-SITE.XML_ozone.recon.om.snapshot.task.interval.delay=1m \
    OZONE-SITE.XML_ozone.datanode.pipeline.limit=1 \
    OZONE-SITE.XML_hdds.scmclient.max.retry.timeout=30s \
    OZONE-SITE.XML_hdds.container.report.interval=60s \
    OZONE-SITE.XML_ozone.scm.stale.node.interval=30s \
    OZONE-SITE.XML_ozone.scm.dead.node.interval=45s \
    OZONE-SITE.XML_hdds.heartbeat.interval=5s \
    OZONE-SITE.XML_ozone.scm.close.container.wait.duration=5s \
    OZONE-SITE.XML_hdds.scm.replication.thread.interval=15s \
    OZONE-SITE.XML_hdds.scm.replication.under.replicated.interval=5s \
    OZONE-SITE.XML_hdds.scm.replication.over.replicated.interval=5s \
    OZONE-SITE.XML_hdds.scm.wait.time.after.safemode.exit=5s \
    OZONE-SITE.XML_ozone.http.basedir=/tmp/ozone_http \
    OZONE-SITE.XML_hdds.container.ratis.datastream.enabled=true \
    OZONE-SITE.XML_ozone.fs.hsync.enabled=true \
    OZONE-SITE.XML_ozone.recon.dn.metrics.collection.minimum.api.delay=5s \
    OZONE-SITE.XML_ozone.filesystem.snapshot.enabled=true \
    OZONE-SITE.XML_ozone.server.default.replication=1 \
    OZONE-SITE.XML_hdds.scm.safemode.min.datanode=1 \
    OZONE-SITE.XML_dfs.container.ratis.datanode.storage.dir=/data/metadata/dn \
    OZONE_CONF_DIR=/etc/hadoop \
    OZONE_LOG_DIR=/var/log/hadoop \
    no_proxy=localhost,127.0.0.1

# Expose all service ports
# SCM ports
EXPOSE 9876 9860
# OM ports
EXPOSE 9874 9862
# DataNode ports
EXPOSE 19864 9882
# S3 Gateway ports
EXPOSE 9878 19878
# Recon ports
EXPOSE 9888
# HttpFS ports
EXPOSE 14000

# Expose volumes for data persistence
VOLUME ["/data/metadata"]
VOLUME ["/data/hdds"]
VOLUME ["/var/log/hadoop"]

# Create startup script and set permissions
COPY --chmod=755 start-all-services.sh /usr/local/bin/start-all-services.sh

# Switch to root to allow volume initialization
USER root

# Set the startup script as the entrypoint
CMD ["/usr/local/bin/start-all-services.sh"]
