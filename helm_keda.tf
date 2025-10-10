# =============================================================================
# KEDA PARA AUTOSCALING BASEADO EM EVENTOS
# =============================================================================
# Instala KEDA para escalonamento baseado em métricas externas

# Chart Helm do KEDA
# Permite HPA baseado em filas, métricas customizadas e eventos externos
resource "helm_release" "keda" {
  count = var.criar_keda ? 1 : 0 # Instalação condicional

  name             = "keda"
  chart            = "keda"
  repository       = "https://kedacore.github.io/charts" # Repositório oficial
  namespace        = "keda"
  create_namespace = true

  depends_on = [
    aws_eks_cluster.main
  ]
}