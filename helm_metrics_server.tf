# =============================================================================
# METRICS SERVER PARA MÉTRICAS DE RECURSOS
# =============================================================================
# Instala Metrics Server para coletar métricas de CPU e memória

# Chart Helm do Metrics Server
# Necessário para HPA funcionar com métricas de CPU/memória
resource "helm_release" "metrics_server" {
  count = var.criar_metrics_server ? 1 : 0 # Instalação condicional

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  #repository = "https://charts.bitnami.com/bitnami" # Repositório Bitnami - Descontinuado
  chart      = "metrics-server"
  namespace  = "kube-system" # Namespace do sistema
  wait       = false         # Não aguarda deploy completo
  #version    = "7.2.16"      # Versão estável

  set = [{
    name  = "apiService.create"
    value = "true" # Cria API service
  }]

  depends_on = [
    aws_eks_cluster.main
  ]
}