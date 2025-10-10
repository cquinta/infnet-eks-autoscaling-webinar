

resource "aws_eks_fargate_profile" "istio" {
  cluster_name         = aws_eks_cluster.main.name
  fargate_profile_name = "istio"

  pod_execution_role_arn = aws_iam_role.fargate.arn

  subnet_ids = data.aws_ssm_parameter.subnets[*].value

  selector {
    namespace = "istio-system"
  }
}

