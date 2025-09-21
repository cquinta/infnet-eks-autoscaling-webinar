resource "helm_release" "metrics_server" {

  count = var.criar_metrics_server ? 1 : 0

  name       = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  namespace  = "kube-system"

  wait = false

  version = "7.2.16"

  set = [{
    name  = "apiService.create"
    value = "true"
    }
  ]
  depends_on = [
    aws_eks_cluster.main,

  ]
}