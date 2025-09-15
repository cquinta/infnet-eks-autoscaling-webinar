resource "aws_lb" "main" {

  name = var.project_name

  internal           = false
  load_balancer_type = "application"

  subnets = data.aws_ssm_parameter.public_subnets[*].value
  security_groups = [
    aws_security_group.main.id
  ]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Name = var.project_name
  }

}

resource "aws_lb_target_group" "main" {
  name     = format("%s-http", var.project_name)
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc.value
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_security_group" "main" {
  name = var.project_name

  vpc_id = data.aws_ssm_parameter.vpc.value

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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