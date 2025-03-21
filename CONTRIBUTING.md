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

# Contributing

For general contribution guideline, please check the [Apache Ozone repository](https://github.com/apache/ozone/blob/master/CONTRIBUTING.md).

Development of the `ozone` image happens on branch `latest`.

## Local Build and Test

### Building

The image can be built simply by running the helper script `build.sh`:

```bash
$ ./build.sh
...
 => => naming to docker.io/apache/ozone:dev
```

This will create a single-platform image for your architecture.

It can be customized via environment variables defined at build time.

```bash
# the URL to download Ozone from; allows using custom tarball or local mirror
OZONE_URL

# version of Ozone to include in the image; ignored if URL is also specified
OZONE_VERSION

# the base image name in repo/image format
OZONE_RUNNER_IMAGE

# the base image version to use
OZONE_RUNNER_VERSION
```

### Testing

The image can be tested locally with the sample Docker Compose definition in this repo, by setting `OZONE_IMAGE_VERSION`:

```bash
export OZONE_IMAGE_VERSION=dev
docker compose up -d --scale datanode=3
```

## GitHub Workflows

If this is your first time working on the image, please enable GitHub Actions workflows after forking the repo.

### Building

Whenever changes are pushed to your fork, GitHub builds a multi-platform image (for `amd64` and `arm64`), and tags it with the commit SHA.  These images can be shared with other developers for feedback.  Workflow runs are listed at `https://github.com/<username>/ozone-docker/actions`, images at `https://github.com/<username>/ozone-docker/pkgs/container/ozone`.

## Publishing Docker Tags (for committers)

Image tags are derived from branch names: push to the branch `ozone-<tag>` gets published with `<tag>` (e.g. `ozone-1.4.1 -> 1.4.1`).

1. Update the version-specific branches (both `ozone-<version>` and `ozone-<version>-rocky`):
   - Branch of the latest release version can usually be updated by fast-forwarding it: `git merge --ff-only origin/latest`.  By applying the exact same commit to multiple branches, the CI workflow can tag the existing image created for the `latest` branch, instead of building completely new images.
   - For other versions the branch can be updated by cherry-picking one or more commits.
2. Push the branch to the origin repo (`apache/ozone-docker`).  This will trigger a workflow run to publish the image.
