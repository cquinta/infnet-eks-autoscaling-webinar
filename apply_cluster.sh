#!/bin/bash



echo "Setup do Cluster"

rm -rf  .terraform

terraform init -backend-config=environment/webinar/backend.tfvars

terraform apply --auto-approve -var-file=environment/webinar/terraform.tfvars

aws eks --region us-east-1 update-kubeconfig --name webinar-infnet



