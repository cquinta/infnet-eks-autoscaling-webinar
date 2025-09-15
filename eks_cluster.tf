# Cluster EKS principal para o webinar de autoscaling
# Configurado com criptografia, logs habilitados e zonal shift para alta disponibilidade
resource "aws_eks_cluster" "main" {
  # Nome do cluster baseado no nome do projeto
  name = var.project_name
  # Versão do Kubernetes a ser utilizada
  version = var.k8s_version

  # Role IAM para o cluster EKS
  role_arn = aws_iam_role.eks_cluster_role.arn

  # Configuração da VPC - utiliza subnets privadas para maior segurança
  vpc_config {
    subnet_ids = data.aws_ssm_parameter.subnets[*].value
  }

  # Configuração de criptografia para secrets do cluster
  encryption_config {
    provider {
      key_arn = aws_kms_key.main.arn
    }
    resources = ["secrets"]
  }

  # Configuração de acesso - permite autenticação via API e ConfigMap
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Tipos de logs habilitados para monitoramento e auditoria
  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  # Configuração de shift de zona para recuperação automática de falhas de AZ
  zonal_shift_config {
    enabled = true
  }

  # Tags para identificação e gerenciamento do cluster
  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "shared"
    CentroDeCusto                               = "webinar-infnet"
  }

  # Dependências necessárias antes da criação do cluster
  depends_on = [aws_iam_role.eks_cluster_role,
    aws_kms_key.main,
  ]

}