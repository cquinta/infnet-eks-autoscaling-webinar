# =============================================================================
# CONFIGURAÇÃO DOS PROVIDERS TERRAFORM
# =============================================================================
# Define os providers necessários para gerenciar recursos AWS e Kubernetes

# Provider AWS - Gerencia recursos da infraestrutura AWS
provider "aws" {
  region = var.region
}

# Provider Kubernetes - Gerencia recursos dentro do cluster EKS
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.default.token
}

# Provider Helm - Instala charts Helm no cluster EKS
provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}

# Configuração de providers obrigatórios
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

# Provider kubectl - Aplica manifestos YAML diretamente no cluster
provider "kubectl" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.default.token
  load_config_file       = false
}