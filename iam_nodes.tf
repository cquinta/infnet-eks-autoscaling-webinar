# =============================================================================
# CONFIGURAÇÕES IAM PARA OS NÓS WORKER DO EKS
# =============================================================================
# Este arquivo define as permissões IAM necessárias para os nós worker
# do EKS funcionarem corretamente

# Documento de política que permite às instâncias EC2 assumir a role
data "aws_iam_policy_document" "nodes" {
  version = "2012-10-17"

  statement {
    # Permite a ação de assumir role
    actions = [
      "sts:AssumeRole"
    ]

    # Define que apenas instâncias EC2 podem assumir esta role
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

# Role IAM para os nós worker do EKS
# Esta role é assumida pelas instâncias EC2 que funcionam como worker nodes
resource "aws_iam_role" "eks_nodes_role" {
  name               = format("%s-nodes-role", var.project_name)
  assume_role_policy = data.aws_iam_policy_document.nodes.json
}

# Política CNI - permite gerenciar interfaces de rede para pods
resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

# Política de worker nodes - permissões básicas para nós EKS
resource "aws_iam_role_policy_attachment" "nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

# Política ECR - permite baixar imagens de container do ECR
resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

# Política SSM - permite gerenciamento via Systems Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodes_role.name
}

# Política CloudWatch - permite envio de métricas e logs
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

# Perfil de instância para anexar a role às instâncias EC2
resource "aws_iam_instance_profile" "nodes" {
  name = var.project_name
  role = aws_iam_role.eks_nodes_role.name
}