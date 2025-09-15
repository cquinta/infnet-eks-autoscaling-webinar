


resource "helm_release" "cluster_autoscaler" {
  count = var.criar_cluster_autoscaler ? 1 : 0

  repository = "https://kubernetes.github.io/autoscaler"

  chart = "cluster-autoscaler"
  name  = "aws-cluster-autoscaler"

  namespace        = "kube-system"
  create_namespace = true


  set = [{
    name  = "replicaCount"
    value = 1
    },
    {
      name  = "awsRegion"
      value = var.region
    },

    {
      name  = "rbac.serviceAccount.create"
      value = true
    },
    #{
    #  name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    #  value = aws_iam_role.autoscaler.arn
    #},

    { name  = "serviceAccount.create"
      value = true
    },

    {
      name  = "serviceAccount.name"
      value = "aws-cluster-autoscaler"
    },

    {
      name  = "autoscalingGroups[0].name"
      value = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
    },

    {
      name  = "autoscalingGroups[0].maxSize"
      value = lookup(var.auto_scale_options, "max")
    },

    {
      name  = "autoscalingGroups[0].minSize"
      value = lookup(var.auto_scale_options, "min")
    },
    {
      name  = "extraArgs.scan-interval"
      value = "5s"
    },
    {
      name  = "extraArgs.scan-interval"
      value = "5s"
    },
    {
      name  = "extraArgs.scale-down-utilization-threshold"
      value = "0.6"
    },
    {
      name  = "extraArgs.scale-down-non-empty-candidates-count"
      value = 30
    },
    {
      name  = "extraArgs.scale-down-delay-after-add"
      value = "1m"
    },

    {
      name  = "extraArgs.scale-down-unneeded-time"
      value = "1m"
    }

  ]

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role.autoscaler
  ]
}