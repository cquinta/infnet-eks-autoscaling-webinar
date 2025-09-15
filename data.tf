# Obtém o token de autenticação para o cluster EKS
# Necessário para configurar o provider Kubernetes
data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.main.id
}

# Obtém informações da conta AWS atual
# Usado para referências de ARN e identificação da conta
data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc" {
  name = var.ssm_vpc
}

data "aws_ssm_parameter" "subnets" {
  count = length(var.ssm_subnets)
  name  = var.ssm_subnets[count.index]
}

data "aws_ssm_parameter" "public_subnets" {
  count = length(var.ssm_public_subnets)
  name  = var.ssm_public_subnets[count.index]
}

