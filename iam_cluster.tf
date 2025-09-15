# =============================================================================
# CONFIGURAÇÕES IAM PARA O CLUSTER EKS
# =============================================================================
# Este arquivo define as permissões IAM necessárias para o cluster EKS
# funcionar corretamente na AWS

# Documento de política que permite ao serviço EKS assumir a role
data "aws_iam_policy_document" "cluster" {
  version = "2012-10-17"

  statement {
    # Permite a ação de assumir role
    actions = [
      "sts:AssumeRole"
    ]

    # Define que apenas o serviço EKS pode assumir esta role
    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com"
      ]
    }
  }
}

# Role IAM para o cluster EKS
# Esta role é assumida pelo serviço EKS para gerenciar o cluster
resource "aws_iam_role" "eks_cluster_role" {
  name               = format("%s-cluster-role", var.project_name)
  assume_role_policy = data.aws_iam_policy_document.cluster.json
}

# Anexa a política gerenciada do EKS à role do cluster
# Esta política contém as permissões necessárias para o cluster funcionar
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Anexa a política de serviço do EKS (legacy, mas ainda recomendada)
# Fornece permissões adicionais para operações do cluster
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}