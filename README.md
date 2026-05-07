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

# Apache Ozone Quick Start

Get started with Apache Ozone in 5 minutes using a single-container setup with the AWS S3 CLI.

## What is the Quickstart Image?

The quickstart image is a single-container version of Apache Ozone that runs all services (SCM, OM, DataNode, S3 Gateway, Recon, HttpFS). It's designed for:

- Quick development and testing
- Learning Ozone functionality
- Demos and POCs
- Local S3-compatible storage

> **Note**: For production deployments, use the [multi-container setup](docker-compose.yaml) with separate containers for each service.

For runtime configuration overrides, see [ADVANCED.md](ADVANCED.md).

## Prerequisites

- Docker installed
- AWS CLI installed (optional, for S3 testing)
  - macOS: `brew install awscli`
  - pip: `pip install awscli`

## Quick Start

### Step 1: Start Ozone

```bash
docker run -d \
  --name ozone \
  -p 9878:9878 \
  -p 9888:9888 \
  -v ozone-metadata:/data/metadata \
  -v ozone-hdds:/data/hdds \
  -v ozone-logs:/var/log/hadoop \
  apache/ozone:all-in-one

# Wait 10-30 seconds for services to start
docker logs -f ozone
```

### Step 2: Configure AWS CLI

Set up AWS CLI to point to Ozone's S3 Gateway:

```bash
# Configure credentials (use any value for local testing)
aws configure set aws_access_key_id ozone
aws configure set aws_secret_access_key ozone
aws configure set default.s3.signature_version s3v4
```

**Note**: For this single-node cluster, authentication is minimal. Use any credentials.

### Step 3: Create a Bucket

```bash
# Create bucket
aws s3api create-bucket \
  --bucket mybucket \
  --endpoint-url http://localhost:9878

# List all buckets
aws s3 ls --endpoint-url http://localhost:9878
```

### Step 4: Upload and Download Files

```bash
# Create a test file
echo "Hello, Ozone!" > test.txt

# Upload file
aws s3 cp test.txt s3://mybucket/mykey.txt \
  --endpoint-url http://localhost:9878

# List keys in bucket
aws s3 ls s3://mybucket/ --endpoint-url http://localhost:9878

# Download file
aws s3 cp s3://mybucket/mykey.txt downloaded.txt \
  --endpoint-url http://localhost:9878

# Verify content
cat downloaded.txt
```

## Common Operations

### Upload Directory
```bash
aws s3 sync ./local-folder/ s3://mybucket/remote-folder/ \
  --endpoint-url http://localhost:9878
```

### Download Directory
```bash
aws s3 sync s3://mybucket/remote-folder/ ./local-folder/ \
  --endpoint-url http://localhost:9878
```

### Delete Objects
```bash
aws s3 rm s3://mybucket/ --recursive --endpoint-url http://localhost:9878
```

### Copy Between Buckets
```bash
aws s3 cp s3://source-bucket/file.txt s3://dest-bucket/file.txt \
  --endpoint-url http://localhost:9878
```

## Using Ozone Native CLI

If you prefer Ozone's native CLI instead of S3:

```bash
# Enter the container
docker exec -it ozone bash

# Create a volume
ozone sh volume create /vol1

# Create a bucket
ozone sh bucket create /vol1/bucket1

# Upload key
echo "Hello Ozone" > /tmp/test.txt
ozone sh key put /vol1/bucket1/key1 /tmp/test.txt

# Download key
ozone sh key get /vol1/bucket1/key1 /tmp/test-out.txt

# List keys
ozone sh key list /vol1/bucket1/
```

## Web UIs

Access Ozone's web interfaces:

- **Recon Dashboard**: http://localhost:9888 - Visual overview of volumes, buckets, and keys
- **S3 Gateway**: http://localhost:9878

## Managing the Container

### Stop the Container
```bash
docker stop ozone
```

### Restart the Container
```bash
docker start ozone
```

### Remove the Container
```bash
docker rm ozone
```

### Remove Volumes (Start Fresh)
```bash
docker volume rm ozone-metadata ozone-hdds ozone-logs
```

### Check Logs
```bash
# All services
docker logs ozone

# Specific service
docker exec ozone tail -f /var/log/hadoop/scm.log
docker exec ozone tail -f /var/log/hadoop/om.log
docker exec ozone tail -f /var/log/hadoop/datanode.log
docker exec ozone tail -f /var/log/hadoop/s3g.log
docker exec ozone tail -f /var/log/hadoop/recon.log
```

## Troubleshooting

### Container Exits Immediately

Check the logs:
```bash
docker logs ozone
```

Ensure you have allocated enough resources to Docker (at least 4GB RAM recommended).

### SCM Not Exiting Safe Mode

Wait 10-30 seconds after startup. Check status:
```bash
docker exec ozone ozone admin safemode status --verbose
```

### Permission Errors

If using host-mounted directories instead of Docker volumes, ensure proper permissions:
```bash
mkdir -p ./ozone-metadata ./ozone-hdds ./ozone-logs
chmod -R 777 ./ozone-metadata ./ozone-hdds ./ozone-logs
```

### Reset and Start Fresh

```bash
# Stop and remove container
docker stop ozone
docker rm ozone

# Remove all volumes
docker volume rm ozone-metadata ozone-hdds ozone-logs

# Start fresh
docker run -d \
  --name ozone \
  -p 9878:9878 -p 9888:9888 \
  -v ozone-metadata:/data/metadata \
  -v ozone-hdds:/data/hdds \
  -v ozone-logs:/var/log/hadoop \
  apache/ozone:all-in-one
```

## Next Steps

- Visit [Apache Ozone documentation](https://ozone.apache.org/docs/)
- See [ADVANCED.md](ADVANCED.md) for runtime configuration overrides

---

**That's it!** You now have a running Ozone cluster with S3-compatible storage.
