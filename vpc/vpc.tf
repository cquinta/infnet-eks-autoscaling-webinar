# Cria a VPC principal do projeto

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # CIDR principal: 10.0.0.0/16
  enable_dns_support   = true         # Habilita resolução DNS
  enable_dns_hostnames = true         # Habilita hostnames DNS
  tags = {
    Name          = var.project_name,
    CentroDeCusto = "webinar-infnet"
  }
}

# Adiciona blocos CIDR secundários à VPC (para pods EKS)
resource "aws_vpc_ipv4_cidr_block_association" "main" {
  count      = length(var.vpc_additional_cidrs) # Quantidade de CIDRs adicionais
  vpc_id     = aws_vpc.main.id                  # Referência à VPC criada
  cidr_block = var.vpc_additional_cidrs[count.index]
}