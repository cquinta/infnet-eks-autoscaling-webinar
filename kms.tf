# Chave KMS para criptografia do cluster EKS
# Esta chave será utilizada para criptografar secrets do EKS e outros dados sensíveis
resource "aws_kms_key" "main" {
  description             = "Chave KMS para cluster EKS ${var.project_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name          = "${var.project_name}-kms-key"
    Purpose       = "Criptografia do cluster EKS"
    CentroDeCusto = "webinar-infnet"
  }
}

# Alias da Chave KMS para referência mais fácil
# Fornece um nome legível para a chave KMS
resource "aws_kms_alias" "main" {
  name          = format("alias/%s-eks", var.project_name)
  target_key_id = aws_kms_key.main.key_id
}