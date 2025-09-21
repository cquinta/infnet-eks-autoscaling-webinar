


# =============================================================================
# CLUSTER AUTOSCALER VIA HELM
# =============================================================================
# Instala o Cluster Autoscaler para escalonamento automático de nós

# Chart Helm do Cluster Autoscaler
# Escala automaticamente o número de nós baseado na demanda de pods
resource "helm_release" "cluster_autoscaler" {
  count = var.criar_cluster_autoscaler ? 1 : 0  # Condicional via variável

  repository = "https://kubernetes.github.io/autoscaler"  # Repositório oficial
  chart      = "cluster-autoscaler"
  name       = "aws-cluster-autoscaler"
  namespace  = "kube-system"
  create_namespace = true

  # Configurações do Cluster Autoscaler
  set = [
    {
      name  = "replicaCount"
      value = 1                 # Uma única réplica
    },
    {
      name  = "awsRegion"
      value = var.region        # Região AWS
    },
    {
      name  = "rbac.serviceAccount.create"
      value = true              # Cria service account com RBAC
    },
    {
      name  = "serviceAccount.create"
      value = true
    },
    {
      name  = "serviceAccount.name"
      value = "aws-cluster-autoscaler"
    },
    {
      name  = "autoscalingGroups[0].name"
      value = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
    },
    {
      name  = "autoscalingGroups[0].maxSize"
      value = lookup(var.auto_scale_options, "max")  # Tamanho máximo
    },
    {
      name  = "autoscalingGroups[0].minSize"
      value = lookup(var.auto_scale_options, "min")  # Tamanho mínimo
    },
    {
      name  = "extraArgs.scan-interval"
      value = "5s"              # Intervalo de verificação
    },
    {
      name  = "extraArgs.scale-down-utilization-threshold"
      value = "0.6"             # Limite para reduzir nós (60%)
    },
    {
      name  = "extraArgs.scale-down-non-empty-candidates-count"
      value = 30                # Número de candidatos para remoção
    },
    {
      name  = "extraArgs.scale-down-delay-after-add"
      value = "1m"              # Delay após adicionar nó
    },
    {
      name  = "extraArgs.scale-down-unneeded-time"
      value = "1m"              # Tempo para considerar nó desnecessário
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role.autoscaler
  ]
}