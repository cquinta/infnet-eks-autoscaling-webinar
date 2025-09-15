# Configuração do backend S3 para armazenar o estado do Terraform
terraform {
  backend "s3" {
    # Configurações específicas são passadas via arquivo backend.tfvars
    # Exemplo: bucket, key, region, dynamodb_table

  }
}