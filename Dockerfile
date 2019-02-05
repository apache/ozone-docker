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

FROM apache/hadoop-runner
ARG OZONE_URL=https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hadoop/ozone/ozone-0.3.0-alpha/hadoop-ozone-0.3.0-alpha.tar.gz
WORKDIR /opt
RUN sudo rm -rf /opt/hadoop && wget $OZONE_URL -O ozone.tar.gz && tar zxf ozone.tar.gz && rm ozone.tar.gz && mv ozone* hadoop
WORKDIR /opt/hadoop
ADD log4j.properties /opt/hadoop/etc/hadoop/log4j.properties
ADD ozone-site.xml /opt/hadoop/etc/hadoop/ozone-site.xml
RUN sudo chown -R hadoop:users /opt/hadoop/etc/hadoop/*
ADD start-ozone-all.sh /usr/local/bin/start-ozone-all.sh
ADD docker-compose.yaml /opt/hadoop/
ADD docker-config /opt/hadoop/
CMD ["/usr/local/bin/start-ozone-all.sh"]
