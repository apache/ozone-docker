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

# Advanced Configuration

The all-in-one image ships with sensible defaults baked into [`conf/ozone-site.xml`](conf/ozone-site.xml) and [`conf/core-site.xml`](conf/core-site.xml). These cover a single-DataNode cluster with replication of 1.

For one-off tweaks at runtime, you can override individual properties without rebuilding the image by mounting a custom config file.

## Override via mounted config

Create your own `ozone-site.xml` that contains only the properties you want to change, then mount it on top of the baked-in copy:

```bash
docker run -d \
  --name ozone \
  -p 9878:9878 -p 9888:9888 \
  -v "$(pwd)/my-ozone-site.xml:/etc/hadoop/ozone-site.xml:ro" \
  -v ozone-metadata:/data/metadata \
  -v ozone-hdds:/data/hdds \
  -v ozone-logs:/var/log/hadoop \
  apache/ozone:all-in-one
```

> **Note**: When you mount over `ozone-site.xml`, it fully replaces the baked-in file. Copy the original from [`conf/ozone-site.xml`](conf/ozone-site.xml) and edit only what you need.
