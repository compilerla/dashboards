#!/usr/bin/env bash
# auth to gcloud

set -euo pipefail

gcloud auth application-default login
gcloud auth application-default set-quota-project data-warehouse-492522

gcloud auth login
gcloud config set project data-warehouse-492522
