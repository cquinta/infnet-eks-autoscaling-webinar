# Internet Gateway - Permite conectividade bidirecional entre VPC e internet
# Essencial para subnets públicas e NAT Gateways
resource "aws_internet_gateway" "main" {
  # Associa o IGW à VPC principal
  vpc_id = aws_vpc.main.id

  # Tags para identificação e controle de custos
  tags = {
    Name          = var.project_name, # Nome do projeto: "webinar-vpc"
    CentroDeCusto = "webinar-infnet"  # Tag para rastreamento financeiro
  }
}