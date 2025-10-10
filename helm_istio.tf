# =============================================================================
# ISTIO SERVICE MESH VIA HELM
# =============================================================================
# Instala o Istio para observabilidade e gerenciamento de tráfego

# Istio Base - Componentes fundamentais do Istio
resource "helm_release" "istio_base" {
  count = var.criar_istio ? 1 : 0 # Instalação condicional

  name             = "istio-base"
  chart            = "base"
  repository       = "https://istio-release.storage.googleapis.com/charts" # Repo oficial
  namespace        = "istio-system"
  create_namespace = true
  #version          = var.istio_version

  depends_on = [
    aws_eks_cluster.main,
    aws_lb.main
  ]
}

# Istiod - Plano de controle do Istio
resource "helm_release" "istiod" {
  count = var.criar_istio ? 1 : 0

  name             = "istio"
  chart            = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true
  #version          = var.istio_version

  set = [
    {
      name  = "sidecarInjectorWebhook.rewriteAppHTTPProbe"
      value = "false" # Não reescreve probes HTTP
    },
    {
      name  = "meshConfig.enableTracing"
      value = "true" # Habilita tracing distribuído
    },
    {
      name  = "meshConfig.defaultConfig.tracing.zipkin.address"
      value = "jaeger-collector.tracing.svc.cluster.local:9411" # Endpoint Jaeger
    }
  ]

  depends_on = [
    helm_release.istio_base
  ]
}

# Istio Ingress Gateway - Ponto de entrada do service mesh
resource "helm_release" "istio_ingress" {
  count = var.criar_istio ? 1 : 0

  name             = "istio-ingressgateway"
  chart            = "gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true
 # version          = var.istio_version

  set = [
    {
      name  = "service.type"
      value = "NodePort" # Usa NodePort para integração com ALB
    },
    {
      name  = "autoscaling.minReplicas"
      value = var.istio_min_replicas # Mínimo de réplicas
    },
    {
      name  = "autoscaling.targetCPUUtilizationPercentage"
      value = var.istio_cpu_threshold # Threshold de CPU para HPA
    }
  ]

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

# Target Group Binding - Conecta Istio Gateway ao ALB
resource "kubectl_manifest" "target_binding_80" {
  count = var.criar_istio ? 1 : 0

  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: istio-ingress
  namespace: istio-system
spec:
  serviceRef:
    name: istio-ingressgateway
    port: 80
  targetGroupARN: ${aws_lb_target_group.main.arn}  # ARN do Target Group
  targetType: instance
YAML
  depends_on = [
    helm_release.istio_ingress
  ]
}

resource "kubectl_manifest" "mock_gateway" {

  count = var.criar_istio ? 1 : 0

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: mock-istio
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
    - mock-istio.istio-system.svc.cluster.local
YAML
  depends_on = [
    helm_release.istio_ingress
  ]
}


resource "kubectl_manifest" "mock_virtual_service" {

  count = var.criar_istio ? 1 : 0

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: mock-istio
  namespace: istio-system
spec:
  hosts:
  -  mock-istio.istio-system.svc.cluster.local
  http:
  - match:
    - uri:
        exact: /
    directResponse:
      status: 200
      body:
        string: "OK"
YAML
  depends_on = [
    helm_release.istio_ingress
  ]
}

