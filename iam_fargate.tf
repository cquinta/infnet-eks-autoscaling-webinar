data "aws_iam_policy_document" "fargate" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fargate" {
  name               = "${var.project_name}-fargate"
  assume_role_policy = data.aws_iam_policy_document.fargate.json
}

resource "aws_iam_role_policy_attachment" "fargate" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

resource "aws_iam_role_policy_attachment" "cni_fargate" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.fargate.name
}
