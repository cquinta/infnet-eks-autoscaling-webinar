# =============================================================================
# PARÂMETROS DO SYSTEMS MANAGER PARA RECURSOS DE REDE
# =============================================================================
# Armazena IDs de recursos de rede no Parameter Store para reutilização
# por outros módulos e stacks do Terraform

# Armazena o ID da VPC principal no Parameter Store
# Permite que outros recursos referenciem a VPC de forma desacoplada
resource "aws_ssm_parameter" "vpc" {
  name = "/${var.project_name}/vpc/id"
  type = "String"

  value = aws_vpc.main.id
}

# Armazena os IDs das subnets públicas no Parameter Store
# Organizados por zona de disponibilidade e nome para fácil localização
resource "aws_ssm_parameter" "public_subnets" {
  count = length(aws_subnet.public)

  name  = "/${var.project_name}/subnets/public/${var.public_subnets[count.index].availability_zone}/${var.public_subnets[count.index].name}"
  type  = "String"
  value = aws_subnet.public[count.index].id
}

# Armazena os IDs das subnets privadas no Parameter Store
# Utilizadas pelos worker nodes do EKS e outros recursos internos
resource "aws_ssm_parameter" "private_subnets" {
  count = length(aws_subnet.private)

  name  = "/${var.project_name}/subnets/private/${var.private_subnets[count.index].availability_zone}/${var.private_subnets[count.index].name}"
  type  = "String"
  value = aws_subnet.private[count.index].id
}

