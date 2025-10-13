data "aws_iam_policy_document" "keda_role" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

   ### Descomentar para o Keda com SQS ###
   # principals {
   #   type        = "AWS"
   #   identifiers = ["arn:aws:iam::707257249187:role/webinar-infnet-keda"]
   # }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}


resource "aws_iam_role" "keda_role" {
  assume_role_policy = data.aws_iam_policy_document.keda_role.json
  name               = format("%s-keda", var.project_name)
}

data "aws_iam_policy_document" "keda_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueues",
      "sqs:ListMessageMoveTasks",
      "sqs:ListQueueTags"
      
    ]

    resources = [
      "*"
    ]

  }
}

resource "aws_iam_policy" "keda_policy" {
  name        = format("%s-keda", var.project_name)
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.keda_policy.json
}

resource "aws_iam_policy_attachment" "keda" {
  name = "keda"
  roles = [
    aws_iam_role.keda_role.name
  ]

  policy_arn = aws_iam_policy.keda_policy.arn
}

resource "aws_eks_pod_identity_association" "keda" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "keda"
  service_account = "keda-operator"
  role_arn        = aws_iam_role.keda_role.arn
}