# =============================================================================
# SECURITY GROUP PARA EFS (ELASTIC FILE SYSTEM)
# =============================================================================
# Define regras de firewall para acesso aos volumes EFS

# Security Group para o EFS
resource "aws_security_group" "efs" {
  name   = format("%s-efs", var.project_name)
  vpc_id = data.aws_ssm_parameter.vpc.value

  # Regra de entrada - permite acesso NFS na porta 2049
  ingress {
    from_port   = 2049          # Porta padrão do NFS
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso de toda a VPC
  }

  # Regra de saída - permite todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # Todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}