#!/bin/bash
# init.sh — importa recursos solo si no están en el estado

AMBIENTE=${1:-certificacion}

echo "🔍 Verificando recursos en estado Terraform..."

# Función para importar solo si no existe en el estado
importar_si_no_existe() {
  local RESOURCE=$1
  local ID=$2

  if terraform state show "$RESOURCE" > /dev/null 2>&1; then
    echo "✅ $RESOURCE ya está en el estado, se omite importación"
  else
    echo "📥 Importando $RESOURCE..."
    terraform import "$RESOURCE" "$ID"
  fi
}

# Inicializar
terraform init

# Importar recursos que pueden existir previamente

importar_si_no_existe \
  "aws_kms_alias.sri_secrets" \
  "alias/sri-secrets"

importar_si_no_existe \
  "aws_secretsmanager_secret.certificado_p12" \
  "sri/certificacion/certificado-p12"

importar_si_no_existe \
  "aws_secretsmanager_secret.certificado_password" \
  "sri/certificacion/certificado-password"


importar_si_no_existe \
  "aws_iam_role.lambda_sri" \
  "rol-fact-lambda-sri-${AMBIENTE}"

# importar_si_no_existe \
#   "aws_iam_policy.leer_secrets_sri" \
#   "pol-fact-leer-secrets-sri-${AMBIENTE}"

# importar_si_no_existe \
#   "aws_iam_policy.lambda_s3_sri" \
#   "pol-fact-s3-lambda-sri-${AMBIENTE}"


# importar_si_no_existe \
#    "aws_iam_policy.lambda_logs_sri" \
#    "pol-fact-logs-lambda-sri-${AMBIENTE}"


echo "✅ Verificación completa"
echo "✅ Ejecutando terraform plan..."
terraform plan

echo "🚀 Ejecutando terraform apply..."
terraform apply
