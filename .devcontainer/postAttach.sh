#!/usr/bin/env bash
# postCreate.sh - Script executed after the dev container is attached to the host

set -euo pipefail

gcloud auth application-default login
gcloud auth application-default set-quota-project data-warehouse-492522
