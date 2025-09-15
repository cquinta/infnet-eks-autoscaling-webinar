#!/bin/bash



echo "***Destroy do Cluster***"

rm -rf  .terraform
terraform init -backend-config=environment/webinar/backend.tfvars
terraform destroy -var-file=environment/webinar/terraform.tfvars --auto-approve





