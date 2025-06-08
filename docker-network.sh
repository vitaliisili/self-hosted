#!/bin/bash

NETWORK_NAME="selfhosted_net"

if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  echo "Docker network '$NETWORK_NAME' already exists. Skipping."
else
  echo "Creating Docker network '$NETWORK_NAME'..."
  docker network create "$NETWORK_NAME"
fi
