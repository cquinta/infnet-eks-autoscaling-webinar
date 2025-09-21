# =============================================================================
# REGRAS DE SECURITY GROUP PARA O CLUSTER EKS
# =============================================================================
# Define regras de firewall para o cluster EKS

# Regra de ingresso para o cluster EKS
# ATENÇÃO: Esta regra permite todo o tráfego - apenas para ambiente de teste
resource "aws_security_group_rule" "cluster" {
  cidr_blocks       = ["0.0.0.0/0"]  # Todo o tráfego da internet
  from_port         = 0
  to_port           = 0
  protocol          = "-1"            # Todos os protocolos
  description       = "all"
  type              = "ingress"
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}