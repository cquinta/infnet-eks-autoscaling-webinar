
# Cria subnets públicas em múltiplas AZs

resource "aws_subnet" "public" {
  count = length(var.public_subnets) # Cria 3 subnets (uma por AZ)

  vpc_id = aws_vpc.main.id # Associa à VPC principal

  cidr_block        = var.public_subnets[count.index].cidr              # CIDR da subnet
  availability_zone = var.public_subnets[count.index].availability_zone # AZ específica

  tags = {
    Name          = var.public_subnets[count.index].name,
    CentroDeCusto = "webinar-infnet"
  }

  # Aguarda a criação dos CIDRs adicionais
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.main
  ]
}

# Tabela de roteamento para subnets públicas
resource "aws_route_table" "public_internet_access" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name          = "${var.project_name}-public-access",
    CentroDeCusto = "webinar-infnet"
  }
}

# Rota padrão para internet via Internet Gateway
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public_internet_access.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.main.id
}

# Associa subnets públicas à tabela de roteamento
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_internet_access.id
}