# =============================================================================
# ENTRADAS DE ACESSO DO EKS
# =============================================================================
# Define permissões de acesso para roles IAM no cluster EKS

# Entrada de acesso para os nós worker do EKS
# Permite que as instâncias EC2 se registrem no cluster
resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.eks_nodes_role.arn
  type          = "EC2_LINUX" # Tipo de nó Linux EC2
}

resource "aws_eks_access_entry" "fargate" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.fargate.arn
  type          = "FARGATE_LINUX"
}

