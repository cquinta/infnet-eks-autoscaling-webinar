resource "helm_release" "prometheus" {

  count = var.criar_prometheus ? 1 : 0

  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true

  #version = "69.3.2"

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