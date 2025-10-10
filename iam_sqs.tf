data "aws_iam_policy_document" "sqs" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "sqs" {
  assume_role_policy = data.aws_iam_policy_document.sqs.json
  name               = format("%s-sqs", var.project_name)
}


data "aws_iam_policy_document" "sqs_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "sqs:*",
      "lambda:*"
    ]

    resources = [
      "*"
    ]

  }
}

resource "aws_iam_policy" "sqs" {
  name   = format("%s-sqs", var.project_name)
  path   = "/"
  policy = data.aws_iam_policy_document.sqs_policy.json
}


resource "aws_iam_policy_attachment" "sqs" {
  name = "sqs"
  roles = [
    aws_iam_role.sqs.name
  ]

  policy_arn = aws_iam_policy.sqs.arn
}

resource "aws_eks_pod_identity_association" "sqs" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "moc"
  service_account = "moc-user"
  role_arn        = aws_iam_role.sqs.arn
}