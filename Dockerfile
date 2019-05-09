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
FROM docker:18.09.1-dind
RUN apk add --update --no-cache bash alpine-sdk maven jq grep openjdk8 py-pip rsync procps autoconf automake libtool findutils

#Install real glibc
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk && \
    apk add glibc-2.28-r0.apk

#Install protobuf
RUN mkdir -p /usr/local/src/ && \
    cd /usr/local/src/ && \
    wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz && \
    tar xvf protobuf-2.5.0.tar.gz && \
    cd protobuf-2.5.0 && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    protoc --version

#Findbug install
RUN mkdir -p /opt && \
    curl -sL https://sourceforge.net/projects/findbugs/files/findbugs/3.0.1/findbugs-3.0.1.tar.gz/download | tar -xz  && \
     mv findbugs-* /opt/findbugs

#Install apache-ant
RUN mkdir -p /opt && \
    curl -sL 'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=/ant/binaries/apache-ant-1.10.5-bin.tar.gz' | tar -xz  && \
       mv apache-ant* /opt/ant

#Install docker-compose (for smoketests)
RUN apk add --no-cache libffi-dev libressl-dev python-dev
RUN pip install --upgrade pip
RUN pip install docker-compose

ENV PATH=$PATH:/opt/findbugs/bin

#This is a dirty but powerful hack. We don't know which uid will be used inside the container.
#But for the kerberized unit test we need real users. We assume that the uid will be something 
# between 1 and 5000 and generate all the required users in advance.
RUN addgroup -g 1000 default && \
   mkdir -p /home/user && \
   chmod 777 /home/user && \
   for i in $(seq 1 5000); do adduser jenkins$i -u $i -G default -h /home/user -H -D; done

#This is a very huge local maven cache. Usually the mvn repository is not safe to be 
#shared between builds as concurrent "mvn install" executions are not handled very well.
#A simple workaround is to provide all the required 3rd party lib in the docker image
#It will be cached by docker, and any additional dependency can be downloaded, artifacts
#can be installed
#
#To be sure that we have no dev bits from this build, we will remove org.apache.hadoop files
#from the local maven repository.
USER jenkins1000
RUN cd /tmp && \
   git clone --depth=1 https://github.com/apache/hadoop.git -b trunk && \
   cd /tmp/hadoop && \
   mvn package dependency:go-offline -DskipTests -P hdds -pl :hadoop-ozone-dist -am && \
   rm -rf /home/user/.m2/repository/org/apache/hadoop/*hdds* && \
   rm -rf /home/user/.m2/repository/org/apache/hadoop/*ozone* && \
   rm -rf /tmp/hadoop && \
   find /home/user/.m2/repository -exec chmod o+wx {} \;

USER root

RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
ENV DOCKER_HOST=unix:///var/run/dockeri.sock

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


