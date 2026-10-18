#!/usr/bin/env bash
# postCreate.sh - Script executed after the dev container is created

set -euo pipefail

echo "Installing pre-commit hooks..."
pre-commit install --install-hooks
