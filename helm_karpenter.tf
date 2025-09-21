resource "helm_release" "karpenter" {
  count            = var.criar_karpenter ? 1 : 0
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.3.3"

  set = [
    {
      name  = "settings.clusterName"
      value = var.project_name
    },
    {
      name  = "settings.clusterEndpoint"
      value = aws_eks_cluster.main.endpoint
    },
    {
      name  = "aws.defaultInstanceProfile"
      value = aws_iam_instance_profile.nodes.name
    },
    {
      name  = "controller.resources.requests.cpu"
      value = "1000m"
    },
    {
      name  = "controller.resources.requests.memory"
      value = "1Gi"
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
  ]

}