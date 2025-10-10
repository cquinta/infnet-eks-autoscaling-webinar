# =============================================================================
# KIALI PARA OBSERVABILIDADE DO SERVICE MESH
# =============================================================================
# Instala Kiali para visualização e gerenciamento do Istio

# Chart Helm do Kiali
# Console web para observabilidade do service mesh Istio
resource "helm_release" "kiali-server" {
  count = var.criar_istio ? 1 : 0 # Instala apenas se Istio estiver habilitado

  name             = "kiali-server"
  chart            = "kiali-server"
  repository       = "https://kiali.org/helm-charts" # Repositório oficial
  namespace        = "istio-system"
  create_namespace = true
  version          = var.kiali_version

  set = [
    {
      name  = "server.web_fqdn"
      value = var.kiali_host
    },
    {
      name  = "auth.strategy"
      value = "anonymous"
    },
    {
      name  = "external_services.tracing.use_grpc"
      value = "false"
    },
    {
      name  = "external_services.tracing.enabled"
      value = "true"
    },
    {
      name  = "external_services.tracing.internal_url"
      value = "http://jaeger-query.tracing.svc.cluster.local:16686"
    },
    {
      name  = "external_services.tracing.external_url"
      value = format("http://%s", var.jaeger_host)
    },
    {
      name  = "external_services.prometheus.url"
      value = "http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090"
    },
    {
      name  = "external_services.grafana.enabled"
      value = "true"
    },
    {
      name  = "external_services.grafana.external_url"
      value = format("http://%s", var.grafana_host)
    },
    {
      name  = "external_services.grafana.internal_url"
      value = "http://prometheus-grafana.prometheus.svc.cluster.local:80"
    },
    {
      name  = "external_services.grafana.auth.type"
      value = "basic"
    },
    {
      name  = "external_services.grafana.auth.insecure_skip_verify"
      value = "true"
    },
    {
      name  = "external_services.grafana.auth.username"
      value = "admin"
    },
    {
      name  = "external_services.grafana.auth.password"
      value = "linuxtips"
    },
    {
      name  = "external_services.grafana.dashboards[0].name"
      value = "Istio Mesh Dashboard"
    },
    {
      name  = "external_services.grafana.dashboards[1].name"
      value = "Istio Service Dashboard"
    },
    {
      name  = "external_services.grafana.dashboards[1].variables.namespace"
      value = "var-namespace"
    },
    {
      name  = "external_services.grafana.dashboards[1].variables.service"
      value = "var-service"
    },
    {
      name  = "external_services.grafana.dashboards[2].name"
      value = "Istio Workload Dashboard"
    },
    {
      name  = "external_services.grafana.dashboards[2].variables.namespace"
      value = "var-namespace"
    },
    {
      name  = "external_services.grafana.dashboards[2].variables.workload"
      value = "var-workload"
    },

    {
      name  = "external_services.grafana.dashboards[3].name"
      value = "Istio Performance Dashboard"
    }
  ]

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.istio_ingress
  ]
}

resource "kubectl_manifest" "kiali_gateway" {
  count = var.criar_istio ? 1 : 0

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: kiali-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway 
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - ${var.kiali_host}
YAML

  depends_on = [
    helm_release.kiali-server,
  ]

}

resource "kubectl_manifest" "kiali_virtual_service" {
  count = var.criar_istio ? 1 : 0

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kiali
  namespace: istio-system
spec:
  hosts:
  - ${var.kiali_host}
  gateways:
  - kiali-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: kiali
        port:
          number: 20001
YAML

  depends_on = [
    helm_release.kiali-server,
  ]

}