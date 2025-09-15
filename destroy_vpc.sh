#!/bin/bash




cd vpc/

echo "***Destroy do vpc***"

rm -rf  .terraform
terraform init -backend-config=environment/webinar/backend.tfvars
terraform destroy --auto-approve -var-file=environment/webinar/terraform.tfvars



