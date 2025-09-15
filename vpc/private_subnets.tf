# Subnets privadas para o cluster EKS
# Estas subnets hospedarão os worker nodes do EKS e não terão acesso direto à internet
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id

  cidr_block        = var.private_subnets[count.index].cidr
  availability_zone = var.private_subnets[count.index].availability_zone

  tags = {
    Name          = var.private_subnets[count.index].name,
    CentroDeCusto = "webinar-infnet"
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.main
  ]
}

# Tabelas de roteamento para subnets privadas
# Cada subnet privada terá sua própria tabela de roteamento
resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id
  tags = {
    Name          = format("%s-%s", var.project_name, var.private_subnets[count.index].name),
    CentroDeCusto = "webinar-infnet"
  }
}

# Rotas para acesso à internet via NAT Gateway
# Permite que recursos nas subnets privadas acessem a internet de forma segura
resource "aws_route" "private" {
  count = length(var.private_subnets)

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private[count.index].id

  # Associa cada subnet privada ao NAT Gateway da mesma AZ
  gateway_id = aws_nat_gateway.main[
    index(
      var.public_subnets[*].availability_zone,
      var.private_subnets[count.index].availability_zone
    )
  ].id
}

# Associação das subnets privadas às suas respectivas tabelas de roteamento
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}