# =============================================================================
# JAEGER PARA TRACING DISTRIBUÍDO
# =============================================================================
# Instala Jaeger para observabilidade de traces no service mesh

# Chart Helm do Jaeger
# Coleta e visualiza traces distribuídos das aplicações
resource "helm_release" "jaeger" {
  count = var.criar_istio ? 1 : 0 # Instala apenas se Istio estiver habilitado

  name             = "jaeger"
  repository       = "https://jaegertracing.github.io/helm-charts" # Repo oficial
  chart            = "jaeger"
  namespace        = "tracing"
  create_namespace = true

  set = [
    {
      name  = "allInOne.enabled"
      value = "true" # Modo all-in-one para simplicidade
    },
    {
      name  = "storage.type"
      value = "memory" # Armazenamento em memória (não persistente)
    },
    {
      name  = "agent.enabled"
      value = "false" # Desabilita agent separado
    },
    {
      name  = "collector.enabled"
      value = "false" # Desabilita collector separado
    },
    {
      name  = "query.enabled"
      value = "false" # Desabilita query separado
    },
    {
      name  = "provisionDataStore.cassandra"
      value = "false" # Não provisiona Cassandra
    },
    {
      name  = "provisionDataStore.kafka"
      value = "false" # Não provisiona Kafka
    },
    {
      name  = "provisionDataStore.elasticsearch"
      value = "false" # Não provisiona Elasticsearch
    },
    {
      name  = "collector.service.zipkin.port"
      value = "9411" # Porta para receber traces Zipkin
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    helm_release.istiod
  ]
}

# Gateway Istio para expor Jaeger UI
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
    istio: ingressgateway  # Usa o Istio Ingress Gateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "${var.jaeger_host}"  # Host configurado via variável
YAML

  depends_on = [
    helm_release.jaeger,
    helm_release.istio_ingress
  ]
}

# VirtualService para roteamento do Jaeger
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
          number: 16686  # Porta da UI do Jaeger
YAML

  depends_on = [
    helm_release.jaeger,
    helm_release.istio_ingress
  ]
}