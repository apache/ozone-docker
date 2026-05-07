#!/usr/bin/env bash
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

set -e

echo "Starting Ozone Container..."
echo "Running as user: $(whoami)"

# Initialize SCM if not already initialized
if [ ! -f "/data/metadata/scm/current/VERSION" ]; then
    echo "Initializing SCM..."
    ozone scm --init
fi

# Start SCM in background
echo "Starting Storage Container Manager (SCM)..."
ozone scm > /var/log/hadoop/scm.log 2>&1 &
SCM_PID=$!
echo "SCM started with PID: $SCM_PID"


# Initialize OM if not already initialized
if [ ! -f "/data/metadata/om/current/VERSION" ]; then
    echo "Initializing OM..."
    ozone om --init
fi

# Start OM in background
echo "Starting Ozone Manager (OM)..."
ozone om > /var/log/hadoop/om.log 2>&1 &
OM_PID=$!
echo "OM started with PID: $OM_PID"

# Wait a bit for OM to initialize
sleep 5

# Start DataNode in background
echo "Starting DataNode..."
ozone datanode > /var/log/hadoop/datanode.log 2>&1 &
DN_PID=$!
echo "DataNode started with PID: $DN_PID"

# Start S3 Gateway in background
echo "Starting S3 Gateway..."
ozone s3g > /var/log/hadoop/s3g.log 2>&1 &
S3G_PID=$!
echo "S3 Gateway started with PID: $S3G_PID"

# Start Recon in background
echo "Starting Recon..."
ozone recon > /var/log/hadoop/recon.log 2>&1 &
RECON_PID=$!
echo "Recon started with PID: $RECON_PID"

# Start HttpFS in background
echo "Starting HttpFS..."
ozone httpfs > /var/log/hadoop/httpfs.log 2>&1 &
HTTPFS_PID=$!
echo "HttpFS started with PID: $HTTPFS_PID"

# Wait for SCM to exit safe mode
echo "Waiting for ozone to be ready"
echo "Note: This can take 60-90 seconds"
for i in {1..90}; do
    safemode_output=$(ozone admin safemode status 2>&1)
    if echo "$safemode_output" | grep -q "SCM is out of safe mode"; then
        echo "Ozone is ready"
        break
    fi

    # Show progress every 10 seconds
    if [ $((i % 5)) -eq 0 ]; then
        if echo "$safemode_output" | grep -q "SCM is in safe mode"; then
            echo "  Status: Waiting for Ozone to be ready"
        fi
    fi

    if [ $i -eq 90 ]; then
        echo "Ozone did not exit safe mode within 180 seconds"
        echo "Current safe mode status:"
        ozone admin safemode status --verbose
        echo ""
        tail -50 /var/log/hadoop/scm.log
        echo ""
        echo "Container will continue running, but you may need to manually check safe mode status"
        break
    fi
    sleep 2
done


echo ""
echo "=========================================="
echo "All Ozone services started successfully!"
echo "=========================================="
echo ""
echo "  - S3 Gateway: PID $S3G_PID"
echo "    Endpoint: http://localhost:9878"
echo ""
echo "  - Recon: PID $RECON_PID"
echo "    Web UI: http://localhost:9888"
echo "=========================================="
echo ""

# Function to handle shutdown
shutdown() {
    echo "Shutting down Ozone services..."
    kill $HTTPFS_PID $RECON_PID $S3G_PID $DN_PID $OM_PID $SCM_PID 2>/dev/null || true
    wait $HTTPFS_PID $RECON_PID $S3G_PID $DN_PID $OM_PID $SCM_PID 2>/dev/null || true
    echo "All services stopped."
    exit 0
}

# Trap SIGTERM and SIGINT
trap shutdown SIGTERM SIGINT

# Wait for all background processes
wait -n $SCM_PID $OM_PID $DN_PID $S3G_PID $RECON_PID $HTTPFS_PID

# If any process exits, shutdown all
echo "Ozone exited unexpectedly. Shutting down..."
shutdown
