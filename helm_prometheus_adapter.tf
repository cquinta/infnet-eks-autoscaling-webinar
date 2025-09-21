resource "helm_release" "prometheus_adapter" {

  count = var.criar_metrics_adapter ? 1 : 0




  name             = "prometheus-adapter"
  chart            = "prometheus-adapter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true

  #version = "69.3.2"

  values = [
    "${file("./helm/prometheus/adapter/values.yml")}"
  ]

  depends_on = [
    aws_eks_cluster.main,
    helm_release.prometheus

  ]
}
