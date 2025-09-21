# =============================================================================
# AWS LOAD BALANCER CONTROLLER VIA HELM
# =============================================================================
# Instala o controlador de Load Balancer da AWS para gerenciar ALB/NLB

# Chart Helm do AWS Load Balancer Controller
# Permite criar Application Load Balancers e Network Load Balancers via Ingress
resource "helm_release" "alb_ingress_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"  # Repositório oficial AWS
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"                       # Namespace do sistema
  create_namespace = true

  # Configurações do chart via valores
  set = [
    {
      name  = "clusterName"
      value = var.project_name  # Nome do cluster EKS
    },
    {
      name  = "serviceAccount.create"
      value = true              # Cria service account automaticamente
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "region"
      value = var.region        # Região AWS
    },
    {
      name  = "vpcId"
      value = data.aws_ssm_parameter.vpc.value  # ID da VPC
    }
  ]

  depends_on = [
    aws_eks_cluster.main
  ]
}