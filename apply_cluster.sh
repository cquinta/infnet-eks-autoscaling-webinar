#!/bin/bash



echo "Setup do Cluster"

if [ "$1" = "-initoff" ]; then
    # Se for, exibe uma mensagem e pula a inicialização
    echo "Parâmetro -initoff detectado. Pulando 'terraform init'..."
else
    # Se não, executa o fluxo completo de inicialização
    echo "Executando fluxo completo (init + apply)."
    echo "Limpando diretório .terraform..."
    rm -rf .terraform

    echo "Inicializando o Terraform..."
    terraform init -backend-config=environment/webinar/backend.tfvars
fi
echo "Aplicando a configuração do Terraform..."

terraform apply --auto-approve -var-file=environment/webinar/terraform.tfvars

echo "Atualizando o kubeconfig para o cluster EKS..."

aws eks --region us-east-1 update-kubeconfig --name webinar-infnet



