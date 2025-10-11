# =============================================================================
# VARIÁVEIS DE CONFIGURAÇÃO DO WEBINAR EKS AUTOSCALING
# =============================================================================
# Este arquivo contém todas as variáveis utilizadas na infraestrutura do
# webinar sobre estratégias de autoscaling no Amazon EKS

# -----------------------------------------------------------------------------
# CONFIGURAÇÕES GERAIS DO PROJETO
# -----------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Nome do projeto - usado como prefixo para recursos"
  default     = "aws-eks-webinar"
}

variable "region" {
  type        = string
  description = "Região AWS onde os recursos serão criados"
}


variable "ssm_vpc" {
  type        = string
  description = "Parâmetro SSM que armazena o ID da VPC"
}


variable "ssm_subnets" {
  type = list(string)
}

variable "ssm_public_subnets" {
  type        = list(string)
  description = "Lista dos ID's do SSM onde estão as subnets públicas do projeto"
}

variable "dns_zone" {
  type = string

}

variable "lista_cnames" {
  type = list(string)
  default = [
    "kiali-webinar",
    "grafana-webinar",
    "jaeger-webinar",
    "moc"
  ]
}
# -----------------------------------------------------------------------------
# CONFIGURAÇÕES DO CLUSTER EKS
# -----------------------------------------------------------------------------

variable "k8s_version" {
  type        = string
  description = "Versão do Kubernetes para o cluster EKS"
}

variable "auto_scale_options" {
  type = object({
    min     = number # Número mínimo de nós
    max     = number # Número máximo de nós
    desired = number # Número desejado de nós
  })
  description = "Configurações de autoscaling do grupo de nós"
}

variable "nodes_instance_sizes" {
  type        = list(string)
  description = "Lista de tipos de instância permitidos para os worker nodes"
}

# -----------------------------------------------------------------------------
# VERSÕES DOS ADDONS DO EKS
# -----------------------------------------------------------------------------

variable "addon_cni_version" {
  type        = string
  default     = "v1.19.2-eksbuild.1"
  description = "Versão do addon VPC CNI - gerencia rede dos pods"
}

variable "addon_coredns_version" {
  type        = string
  default     = "v1.11.4-eksbuild.2"
  description = "Versão do addon CoreDNS - serviço de DNS do cluster"
}

variable "addon_kubeproxy_version" {
  type        = string
  default     = "v1.32.0-eksbuild.2"
  description = "Versão do addon Kube-Proxy - gerencia regras de rede"
}

variable "addon_pod_identity_version" {
  type        = string
  default     = "v1.3.4-eksbuild.1"
  description = "Versão do addon Pod Identity - gerencia identidades IAM para pods"
}


#Istio Operator

variable "istio_version" {
  type        = string
  description = "Versão do Istio"
  default     = "1.25.0"
}

variable "istio_min_replicas" {
  type        = string
  description = "value of min replicas"
  default     = "2"
}

variable "istio_max_replicas" {
  type        = string
  description = "value of min replicas"
  default     = "6"
}

variable "istio_cpu_threshold" {
  type        = string
  description = "value of cpu threshold"
  default     = "70"
}

variable "jaeger_host" {
  type        = string
  description = "Host do Jaeger"
  default     = "jaeger-webinar.cquinta.com"
}

variable "kiali_host" {
  type        = string
  description = "Host do Kiali"
  default     = "kiali-webinar.cquinta.com"
}

variable "kiali_version" {
  type        = string
  description = "value of kiali version"
  default     = "2.5.0"
}

# Prometheus Stack

variable "grafana_host" {
  type        = string
  description = "Host do Kiali"
  default     = "grafana-webinar.cquinta.com"
}


variable "addon_efs_csi_version" {
  type        = string
  default     = "v2.1.8-eksbuild.1"
  description = "Versão do Addon do EFS CSI"

}

variable "karpenter_capacity" {
  type = list(object({
    name               = string
    workload           = string
    ami_family         = string
    ami_ssm            = string
    instance_family    = list(string)
    instance_sizes     = list(string)
    capacity_type      = list(string)
    capacity_spread     = list(string)
    availability_zones = list(string)
  }))
}

#flags

variable "criar_cluster_autoscaler" {
  description = "Define se o recurso autscaling deve ser criado (1 para sim, 0 para não)."
  type        = bool
  default     = false
}

variable "criar_prometheus" {
  description = "Define se o recurso prometheus deve ser criado (1 para sim, 0 para não)."
  type        = bool
  default     = false
}

variable "criar_istio" {
  description = "Define se o recurso istio deve ser criado (1 para sim, 0 para não)."
  type        = bool
  default     = false
}

variable "criar_metrics_server" {
  description = "Define se o recurso metrics server deve ser criado (1 para sim, 0 para não)."
  type        = bool
  default     = false
}


variable "criar_metrics_adapter" {
  description = "Define se o recurso metrics adapter deve ser criado (1 para sim, 0 para não)."
  type        = bool
  default     = false
}

variable "criar_keda" {
  description = "Define se o recurso keda deve ser criado (1 para sim, 0 para não)."
  type        = bool
  default     = false
}

variable "criar_karpenter" {
  description = "Define se o recurso karpenter deve ser criado (1 para sim, 0 para não)."
  type        = bool
  default     = false
}

