# Elastic IPs para os NAT Gateways

resource "aws_eip" "eip" {
  count = length(var.public_subnets) # Um EIP por NAT Gateway

  domain = "vpc" # EIP para uso em VPC

  tags = {
    Name          = format("%s-%s", var.project_name, var.public_subnets[count.index].availability_zone),
    CentroDeCusto = "webinar-infnet"
  }
}

# NAT Gateways para conectividade de saída das subnets privadas
resource "aws_nat_gateway" "main" {

  count = length(var.public_subnets) # Um NAT Gateway por AZ

  allocation_id = aws_eip.eip[count.index].id # EIP associado

  subnet_id = aws_subnet.public[count.index].id # Subnet pública onde será criado

  tags = {
    Name          = format("%s-%s", var.project_name, var.public_subnets[count.index].availability_zone),
    CentroDeCusto = "webinar-infnet"
  }
}