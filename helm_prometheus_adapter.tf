# =============================================================================
# PROMETHEUS ADAPTER PARA MÉTRICAS CUSTOMIZADAS
# =============================================================================
# Instala adapter para usar métricas do Prometheus no HPA

# Chart Helm do Prometheus Adapter
# Permite HPA usar métricas customizadas do Prometheus
resource "helm_release" "prometheus_adapter" {
  count = var.criar_metrics_adapter ? 1 : 0 # Instalação condicional

  name             = "prometheus-adapter"
  chart            = "prometheus-adapter"
  repository       = "https://prometheus-community.github.io/helm-charts" # Repo oficial
  namespace        = "prometheus"
  create_namespace = true

  # Arquivo de valores customizados para configuração de métricas
  values = [
    "${file("./helm/prometheus/adapter/values.yml")}"
  ]

  depends_on = [
    aws_eks_cluster.main,
    helm_release.prometheus # Requer Prometheus instalado
  ]
}
