#!/bin/bash

set -e

ENV=$1

if [ $# -ne 1 ]; then
  echo "Usage: $0 <env>"
  exit 1
fi

printf "Initializing Terraform for %s...\n\n" "$ENV"
terraform init

printf "Selecting the Terraform workspace...\n"
if [ "$ENV" = "prod" ]; then
  terraform workspace select default
else
  terraform workspace select "$ENV" || terraform workspace new "$ENV"
fi

echo "Done!"
