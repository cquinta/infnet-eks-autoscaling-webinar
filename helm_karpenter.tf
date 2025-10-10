# =============================================================================
# KARPENTER PARA AUTOSCALING AVANÇADO DE NÓS
# =============================================================================
# Instala Karpenter para provisionamento rápido e eficiente de nós

# Chart Helm do Karpenter
# Alternativa moderna ao Cluster Autoscaler com provisionamento mais rápido
resource "helm_release" "karpenter" {
  count            = var.criar_karpenter ? 1 : 0 # Instalação condicional
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter" # Repositório OCI oficial
  chart      = "karpenter"
  version    = "1.3.3" # Versão estável

  set = [
    {
      name  = "settings.clusterName"
      value = var.project_name # Nome do cluster EKS
    },
    {
      name  = "settings.clusterEndpoint"
      value = aws_eks_cluster.main.endpoint # Endpoint do cluster
    },
    {
      name  = "aws.defaultInstanceProfile"
      value = aws_iam_instance_profile.nodes.name # Perfil IAM dos nós
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1000m" # CPU do controlador
    },
    {
      name  = "controller.resources.requests.memory"
      value = "1Gi" # Memória do controlador
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
  ]
}