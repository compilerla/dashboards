#!/bin/bash

set -e

printf "Initializing Terraform"
terraform init

printf "Selecting the Terraform workspace...\n"
terraform workspace select default

echo "Done!"
