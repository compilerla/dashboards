#!/usr/bin/env bash
# build.sh - Builds local Docker images using Compose

set -euo pipefail

docker compose build --no-cache dev
