# AWS EKS Autoscaling Webinar - Infnet

Repositório do Webinar **AWS Elastic Kubernetes Service: Estratégias de AutoScaling**

## 📋 Visão Geral

Este projeto demonstra a implementação de um cluster Amazon EKS com estratégias avançadas de autoscaling, incluindo infraestrutura como código usando Terraform.

## 🏗️ Arquitetura

- **VPC**: Rede isolada com subnets públicas e privadas
- **EKS Cluster**: Kubernetes gerenciado com addons essenciais
- **Node Groups**: Grupos de nós com autoscaling configurado
- **Segurança**: Criptografia KMS e roles IAM específicas

## 📁 Estrutura do Projeto

```
├── eks_cluster.tf          # Configuração do cluster EKS
├── tnodes.tf              # Grupos de nós worker
├── taddons.tf             # Addons do EKS (CNI, CoreDNS, etc.)
├── vpc.tf                 # VPC e configurações de rede
├── private_subnets.tf     # Subnets privadas para worker nodes
├── public_subnets.tf      # Subnets públicas para NAT Gateways
├── iam_cluster.tf         # Permissões IAM do cluster
├── tiam_nodes.tf          # Permissões IAM dos nós
├── kms.tf                 # Chave de criptografia
├── variables.tf           # Variáveis de configuração
└── environment/webinar/   # Configurações específicas do ambiente
```

## 🚀 Como Usar

### Pré-requisitos
- Terraform >= 1.0
- AWS CLI configurado
- kubectl instalado

### Implantação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd infnet-eks-autoscaling-webinar
```

2. **Configure as variáveis**
```bash
cp environment/webinar/terraform.tfvars.example environment/webinar/terraform.tfvars
# Edite as variáveis conforme necessário
```

3. **Inicialize o Terraform**
```bash
terraform init -backend-config=environment/webinar/backend.tfvars
```

4. **Execute o plano**
```bash
terraform plan -var-file=environment/webinar/terraform.tfvars
```

5. **Aplique a infraestrutura**
```bash
terraform apply -var-file=environment/webinar/terraform.tfvars
```

### Configuração do kubectl

```bash
aws eks update-kubeconfig --region <sua-regiao> --name <nome-do-cluster>
```

## ⚙️ Configurações de Autoscaling

### Cluster Autoscaler
- **Min nodes**: Configurável via `auto_scale_options.min`
- **Max nodes**: Configurável via `auto_scale_options.max`
- **Desired nodes**: Configurável via `auto_scale_options.desired`

### Tipos de Instância
- Configurável via `nodes_instance_sizes`
- Suporte a múltiplos tipos para otimização de custos

## 🔒 Segurança

- **Criptografia**: Secrets criptografados com KMS
- **Rede**: Worker nodes em subnets privadas
- **IAM**: Roles com princípio de menor privilégio
- **Logs**: Auditoria completa habilitada

## 📊 Monitoramento

- **CloudWatch**: Logs e métricas do cluster
- **Systems Manager**: Parâmetros de configuração
- **Zonal Shift**: Recuperação automática de falhas

## 🧹 Limpeza

```bash
terraform destroy -var-file=environment/webinar/terraform.tfvars
```

## 📚 Recursos Adicionais

- [Documentação oficial do EKS](https://docs.aws.amazon.com/eks/)
- [Guia de Autoscaling do EKS](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Webinar Infnet** - AWS Elastic Kubernetes Service: Estratégias de AutoScaling
