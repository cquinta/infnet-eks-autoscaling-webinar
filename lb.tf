# =============================================================================
# APPLICATION LOAD BALANCER PARA O WEBINAR
# =============================================================================
# Cria ALB público para expor aplicações do cluster EKS

# Application Load Balancer principal
resource "aws_lb" "main" {
  name = var.project_name

  internal           = false         # ALB público (internet-facing)
  load_balancer_type = "application" # Tipo Application Load Balancer

  subnets = data.aws_ssm_parameter.public_subnets[*].value # Subnets públicas
  security_groups = [
    aws_security_group.main.id # Security group permissivo
  ]

  enable_cross_zone_load_balancing = true  # Balanceamento entre AZs
  enable_deletion_protection       = false # Permite exclusão (ambiente de teste)

  tags = {
    Name = var.project_name
  }
}

# Target Group para direcionar tráfego HTTP
resource "aws_lb_target_group" "main" {
  name     = format("%s-http", var.project_name)
  port     = 30080 # Porta dos targets
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc.value
  health_check {

    path    = "/"
    matcher = "200-404"
  }
}

# Listener do ALB na porta 80
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80 # Porta de entrada
  protocol          = "HTTP"

  # Ação padrão: encaminhar para target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Security Group para o ALB
# ATENÇÃO: Regras permissivas apenas para ambiente de teste
resource "aws_security_group" "main" {
  name   = var.project_name
  vpc_id = data.aws_ssm_parameter.vpc.value

  # Permite todo tráfego de entrada
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.project_name
  }
}