# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.14.2-buster
RUN GO111MODULE=off go get -u github.com/rexray/gocsi/csc

FROM centos:7.6.1810
RUN yum -y install \
        bzip2-devel \
        gcc gcc-c++ gcc48-c++ \
        git \
        lz4-devel \
        make \
        snappy-devel \
        which \
        zlib-devel
RUN git clone https://github.com/gflags/gflags.git \
      && cd gflags \
      && git checkout v2.0 \
      && ./configure && make && make install
RUN curl -LSs -o zstd-1.1.3.tar.gz https://github.com/facebook/zstd/archive/v1.1.3.tar.gz \
      && tar zxvf zstd-1.1.3.tar.gz \
      && cd zstd-1.1.3 \
      && make && make install
RUN curl -LSs -o rocksdb-6.8.1.tar.gz https://github.com/facebook/rocksdb/archive/v6.8.1.tar.gz \
      && tar xzvf rocksdb-6.8.1.tar.gz \
      && cd rocksdb-6.8.1 \
      && make ldb

FROM centos@sha256:b5e66c4651870a1ad435cd75922fe2cb943c9e973a9673822d1414824a1d0475
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y \
      bzip2 \
      java-11-openjdk \
      jq \
      nmap-ncat \
      python3 python3-pip \
      snappy \
      sudo \
      wget \
      zlib

COPY --from=0 /go/bin/csc /usr/bin/csc
COPY --from=1 /rocksdb-6.8.1/ldb /usr/local/bin/ldb
COPY --from=1 /usr/local/lib /usr/local/lib/

#For executing inline smoketest
RUN pip3 install robotframework

#dumb init for proper init handling
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

#byteman test for development
ADD https://repo.maven.apache.org/maven2/org/jboss/byteman/byteman/4.0.4/byteman-4.0.4.jar /opt/byteman.jar
RUN chmod o+r /opt/byteman.jar

#async profiler for development profiling
RUN mkdir -p /opt/profiler && \
    cd /opt/profiler && \
    curl -L https://github.com/jvm-profiling-tools/async-profiler/releases/download/v1.5/async-profiler-1.5-linux-x64.tar.gz | tar xvz

ENV JAVA_HOME=/usr/lib/jvm/jre/
ENV LD_LIBRARY_PATH /usr/local/lib
ENV PATH /opt/hadoop/libexec:$PATH:/opt/hadoop/bin

RUN groupadd --gid 1000 hadoop
RUN useradd --uid 1000 hadoop --gid 100 --home /opt/hadoop
RUN chmod 755 /opt/hadoop
RUN echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN chown hadoop /opt

#Be prepared for kerbebrizzed cluster
RUN mkdir -p /etc/security/keytabs && chmod -R a+wr /etc/security/keytabs 
ADD krb5.conf /etc/
RUN chmod 644 /etc/krb5.conf
RUN yum install -y krb5-workstation

# CSI / k8s / fuse / goofys dependency
RUN wget https://github.com/kahing/goofys/releases/download/v0.20.0/goofys -O /usr/bin/goofys
RUN chmod 755 /usr/bin/goofys
RUN yum install -y fuse

#Make it compatible with any UID/GID (write premission may be missing to /opt/hadoop
RUN mkdir -p /etc/hadoop && mkdir -p /var/log/hadoop && chmod 1777 /etc/hadoop && chmod 1777 /var/log/hadoop
ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
RUN mkdir /data && chmod 1777 /data

#default entrypoint (used only if the ozone dir is not bindmounted)
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

WORKDIR /opt/hadoop
USER hadoop

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "entrypoint.sh"]
