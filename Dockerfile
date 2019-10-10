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
FROM centos:7.6.1810
RUN yum -y install epel-release
RUN yum -y install gcc gcc-c++ kernel-devel make autoconf automake libtool which \
   java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel\
   docker \
   python-pip \ 
   file python-devel \
   git \
   jq \
   sudo

#Install protobuf
ENV LD_LIBRARY_PATH=/usr/lib
RUN mkdir -p /usr/local/src/ && \
    cd /usr/local/src/ && \
    curl -sL https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz | tar xz && \
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
    curl -sL 'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=/ant/binaries/apache-ant-1.10.7-bin.tar.gz' | tar -xz  && \
       mv apache-ant* /opt/ant

#Install apache-maven
RUN curl -sL 'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz' | tar -xz  && \
        mv apache-maven* /opt/maven

#Install docker-compose (for smoketests)
RUN pip install --upgrade pip
RUN pip install docker-compose

ENV PATH=$PATH:/opt/findbugs/bin:/opt/maven/bin:/opt/ant/bin

#This is a dirty but powerful hack. We don't know which uid will be used inside the container.
#But for the kerberized unit test we need real users. We assume that the uid will be something 
# between 1 and 5000 and generate all the required users in advance.
RUN groupadd -g 1000 default && \
   mkdir -p /home/user && \
   chmod 777 /home/user && \
   for i in $(seq 1 5000); do adduser jenkins$i -u $i -g default -d /home/user -N; done

RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN ln -s /home/user/.m2 /root/.m2

#blockade test
RUN pip install virtualenv && virtualenv /opt/blockade && /opt/blockade/bin/pip install pytest==2.8.7 blockade
ENV PATH=$PATH:/opt/blockade/bin

#kubectl
RUN cd /usr/local/bin && \
   curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
   chmod +x ./kubectl

RUN pip install robotframework

RUN curl -sL https://github.com/muquit/mailsend-go/releases/download/v1.0.5/mailsend-go_1.0.5_linux-64bit.tar.gz | tar zxf - && mv mailsend-go-dir/mailsend-go /usr/local/bin/ && rm -rf mailsend-go-dir

RUN curl -L https://github.com/elek/flekszible/releases/download/v1.5.2/flekszible_1.5.2_Linux_x86_64.tar.gz | tar zx && mv flekszible /usr/local/bin && chmod +x /usr/local/bin/flekszible

USER jenkins1000

#This is a very huge local maven cache. Usually the mvn repository is not safe to be 
#shared between builds as concurrent "mvn install" executions are not handled very well.
#A simple workaround is to provide all the required 3rd party lib in the docker image
#It will be cached by docker, and any additional dependency can be downloaded, artifacts
#can be installed
#
#To be sure that we have no dev bits from this build, we will remove org.apache.hadoop files
#from the local maven repository.

RUN cd /tmp && git clone --depth=1 https://github.com/apache/hadoop.git -b trunk && \
   cd /tmp/hadoop && mvn -B package dependency:go-offline -DskipTests=true -f pom.ozone.xml && \
   rm -rf /home/user/.m2/repository/org/apache/hadoop/*hdds* && \
   rm -rf /home/user/.m2/repository/org/apache/hadoop/*ozone* && \
   rm -rf /tmp/hadoop && \ 
   find /home/user/.m2/repository -exec chmod go+wx {} \;
