resource "helm_release" "jaeger" {
  count = var.criar_istio ? 1 : 0

  name             = "jaeger"
  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  namespace        = "tracing"
  create_namespace = true

  set = [
    {
      name  = "allInOne.enabled"
      value = "true"
    },
    {
      name  = "storage.type"
      value = "memory"
    },
    {
      name  = "agent.enabled"
      value = "false"
    },
    {
      name  = "collector.enabled"
      value = "false"
    },
    {
      name  = "query.enabled"
      value = "false"
    },
    {
      name  = "provisionDataStore.cassandra"
      value = "false"
    },
    {
      name  = "provisionDataStore.kafka"
      value = "false"
    },
    {
      name  = "provisionDataStore.elasticsearch"
      value = "false"
    },
    {
      name  = "collector.service.zipkin.port"
      value = "9411"
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    helm_release.istiod
  ]
}

resource "kubectl_manifest" "jaeger_gateway" {
  count = var.criar_istio ? 1 : 0

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: jaeger-query
  namespace: tracing
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "${var.jaeger_host}"
YAML

  depends_on = [
    helm_release.jaeger,
    helm_release.istio_ingress
  ]

}

resource "kubectl_manifest" "jaeger_virtual_service" {
  count = var.criar_istio ? 1 : 0

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: jaeger-query
  namespace: tracing
spec:
  hosts:
  - "${var.jaeger_host}"
  gateways:
  - jaeger-query
  http:
  - route:
    - destination:
        host: jaeger-query
        port:
          number: 16686 
YAML

  depends_on = [
    helm_release.jaeger,
    helm_release.istio_ingress
  ]

}