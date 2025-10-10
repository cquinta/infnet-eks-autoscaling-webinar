# =============================================================================
# PROMETHEUS STACK PARA MONITORAMENTO
# =============================================================================
# Instala stack completo de monitoramento com Prometheus e Grafana

# Chart Helm do Kube-Prometheus-Stack
# Inclui Prometheus, Grafana, AlertManager e exporters
resource "helm_release" "prometheus" {
  count = var.criar_prometheus ? 1 : 0 # Instalação condicional

  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts" # Repo oficial
  namespace        = "prometheus"
  create_namespace = true

  # Arquivo de valores customizados
  values = [
    "${file("./helm/prometheus/values.yml")}"
  ]

  depends_on = [
    aws_eks_cluster.main
  ]
}

resource "kubectl_manifest" "grafana_gateway" {
  count = var.criar_prometheus ? 1 : 0

  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: grafana
  namespace: prometheus
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "${var.grafana_host}" 
YAML
  depends_on = [helm_release.prometheus, helm_release.istio_ingress]
}

resource "kubectl_manifest" "grafana_virtual_service" {
  count      = var.criar_prometheus ? 1 : 0
  yaml_body  = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana
  namespace: prometheus
spec:
  hosts:
  - "${var.grafana_host}"
  gateways:
  - grafana
  http:
  - route:
    - destination:
        host: prometheus-grafana
        port:
          number: 80 
YAML
  depends_on = [helm_release.prometheus, helm_release.istio_ingress]
}