#!/bin/bash
# importar_todo.sh
AMBIENTE="certificacion"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🔄 Importando todos los recursos existentes..."

# Función helper
importar() {
  local RESOURCE=$1
  local ID=$2
  if terraform state show "$RESOURCE" > /dev/null 2>&1; then
    echo "✅ $RESOURCE ya en estado"
  else
    echo "📥 Importando $RESOURCE..."
    terraform import "$RESOURCE" "$ID" || echo "⚠️  No se pudo importar $RESOURCE"
  fi
}

# IAM
importar "aws_iam_role.lambda_sri" \
  "rol-fact-lambda-sri-${AMBIENTE}"

importar "aws_iam_policy.leer_secrets_sri" \
  "arn:aws:iam::${ACCOUNT_ID}:policy/pol-fact-leer-secrets-sri-${AMBIENTE}"

importar "aws_iam_policy.lambda_logs_sri" \
  "arn:aws:iam::${ACCOUNT_ID}:policy/pol-fact-logs-lambda-sri-${AMBIENTE}"

importar "aws_iam_policy.lambda_s3_sri" \
  "arn:aws:iam::${ACCOUNT_ID}:policy/pol-fact-s3-lambda-sri-${AMBIENTE}"

importar "aws_iam_policy.lambda_sqs_sri" \
  "arn:aws:iam::${ACCOUNT_ID}:policy/pol-fact-sqs-lambda-sri-${AMBIENTE}"

# Lambdas
importar "aws_lambda_function.fact_sri" \
  "fact-sri-${AMBIENTE}"

importar "aws_lambda_function.api_proxy" \
  "api-proxy-sri-${AMBIENTE}"

# SQS
importar "aws_sqs_queue.cola_sri" \
  "https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/cola-fact-sri-${AMBIENTE}"

importar "aws_sqs_queue.cola_sri_muerta" \
  "https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/cola-fact-sri-muerta-${AMBIENTE}"

# Secrets
importar "aws_secretsmanager_secret.certificado_p12" \
  "sri/${AMBIENTE}/certificado-p12"

importar "aws_secretsmanager_secret.certificado_password" \
  "sri/${AMBIENTE}/certificado-password"

# CloudWatch Log Groups
importar "aws_cloudwatch_log_group.lambda_fact_sri" \
  "/aws/lambda/fact-sri-${AMBIENTE}"

echo "✅ Importación completa"
echo "🚀 Ejecutando terraform plan..."
terraform plan