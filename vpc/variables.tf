# =============================================================================
# VARIÁVEIS DE CONFIGURAÇÃO DO WEBINAR EKS AUTOSCALING
# =============================================================================
# Este arquivo contém todas as variáveis utilizadas na infraestrutura do
# webinar sobre estratégias de autoscaling no Amazon EKS

# -----------------------------------------------------------------------------
# CONFIGURAÇÕES GERAIS DO PROJETO
# -----------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Nome do projeto - usado como prefixo para recursos"
  default     = "aws-eks-webinar"
}

variable "region" {
  type        = string
  description = "Região AWS onde os recursos serão criados"
}

# -----------------------------------------------------------------------------
# CONFIGURAÇÕES DE REDE (VPC E SUBNETS)
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR principal da VPC - bloco de endereços IP da rede"
}

variable "vpc_additional_cidrs" {
  type        = list(string)
  default     = []
  description = "Lista de CIDRs adicionais para a VPC - usados para pods EKS"
}

variable "public_subnets" {
  description = "Lista de subnets públicas - para NAT Gateways e Load Balancers"
  type = list(object({
    name              = string # Nome identificador da subnet
    cidr              = string # Bloco CIDR da subnet
    availability_zone = string # Zona de disponibilidade
  }))
}

variable "private_subnets" {
  description = "Lista de subnets privadas - para worker nodes do EKS"
  type = list(object({
    name              = string # Nome identificador da subnet
    cidr              = string # Bloco CIDR da subnet
    availability_zone = string # Zona de disponibilidade
  }))
}



