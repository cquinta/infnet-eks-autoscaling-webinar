# Grupo de nós do EKS configurado para autoscaling
# Utiliza instâncias on-demand com configurações otimizadas para o webinar
resource "aws_eks_node_group" "main" {

  # Identificação do cluster e grupo de nós
  cluster_name    = aws_eks_cluster.main.id
  node_group_name = aws_eks_cluster.main.id

  # Role IAM para os nós worker
  node_role_arn = aws_iam_role.eks_nodes_role.arn

  # Tipos de instância permitidos para os nós
  instance_types = var.nodes_instance_sizes

  # Subnets onde os nós serão criados (subnets para pods)
  subnet_ids = data.aws_ssm_parameter.subnets[*].value

  # Configuração de autoscaling - números mínimo, máximo e desejado de nós
  scaling_config {
    desired_size = lookup(var.auto_scale_options, "desired")
    max_size     = lookup(var.auto_scale_options, "max")
    min_size     = lookup(var.auto_scale_options, "min")
  }

  # Tipo de capacidade - instâncias sob demanda para maior previsibilidade
  #capacity_type = "SPOT"
  capacity_type = "ON_DEMAND"

  # Labels para identificação e seleção de nós pelos pods
  labels = {
    "capacity/os"   = "BOTTLEROCKET"
    "capacity/arch" = "x86_64"
    "capacity/type" = "SPOT"
    "compute-type"  = "ec2"
  }

  # Tags para gerenciamento e identificação
  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }

  # Dependências necessárias antes da criação dos nós
  depends_on = [
    #kubernetes_config_map.aws-auth
    aws_eks_access_entry.nodes
  ]

  # Timeouts para operações do grupo de nós
  timeouts {
    create = "1h"
    update = "2h"
    delete = "2h"
  }

}