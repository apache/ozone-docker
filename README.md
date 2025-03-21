<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

# Apache Ozone Docker Image

[ozone](https://github.com/apache/ozone-docker) is built on top of [ozone-runner](https://github.com/apache/ozone-docker-runner), adding the binaries created for official Ozone releases.

These are used for testing compatibility of various Ozone versions, and upgrade from one version to another.  May also be useful for running quick experiments with specific version of Ozone, without the need to download or rebuild it.

Published to [Docker Hub](https://hub.docker.com/r/apache/ozone) and [GitHub](https://github.com/apache/ozone-docker/pkgs/container/ozone).

Images are tagged by Ozone version numbers and optional flavor.  Flavor `-rocky` was introduced when `ozone-runner` was changed from CentOS to Rocky Linux due to CentOS end-of-life, to avoid breaking things for existing users.  Future images will be published only with Rocky Linux, with and without flavor suffix.
