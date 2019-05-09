#!/bin/sh
set -e
set -x
sudo dockerd \
  -G default \
  --host=unix:///var/run/dockeri.sock \
  --host=tcp://0.0.0.0:2375 & > /tmp/docker.log

exec "$@"

