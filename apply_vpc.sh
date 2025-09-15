#!/bin/bash



cd vpc/

echo "Setup do vpc"

rm -rf  .terraform

terraform init -backend-config=environment/webinar/backend.tfvars

terraform apply --auto-approve -var-file=environment/webinar/terraform.tfvars




