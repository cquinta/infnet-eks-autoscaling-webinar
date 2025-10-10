# =============================================================================
# EFS PARA ARMAZENAMENTO PERSISTENTE DO GRAFANA
# =============================================================================
# Cria sistema de arquivos EFS para dados persistentes do Grafana

# Sistema de arquivos EFS para o Grafana
resource "aws_efs_file_system" "grafana" {
  creation_token   = format("%s-efs-grafana", var.project_name)
  performance_mode = "generalPurpose" # Modo de performance balanceado

  tags = {
    Name = format("%s-efs-grafana", var.project_name)
  }
}

# Mount targets do EFS em cada subnet privada
# Permite acesso ao EFS de todas as zonas de disponibilidade
resource "aws_efs_mount_target" "grafana" {
  count = length(data.aws_ssm_parameter.subnets)

  file_system_id = aws_efs_file_system.grafana.id
  subnet_id      = data.aws_ssm_parameter.subnets[count.index].value
  security_groups = [
    aws_security_group.efs.id # Security group com regras NFS
  ]
}

# StorageClass Kubernetes para usar o EFS do Grafana
# Permite que pods solicitem volumes persistentes usando este EFS
resource "kubectl_manifest" "grafana_efs_storage_class" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-grafana
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap      # Usa access points do EFS
  fileSystemId: ${aws_efs_file_system.grafana.id}
  directoryPerms: "777"         # Permissões de diretório
reclaimPolicy: Retain           # Mantém dados após exclusão do PVC
volumeBindingMode: WaitForFirstConsumer  # Cria volume quando pod é agendado
YAML

  depends_on = [
    aws_eks_cluster.main
  ]
}