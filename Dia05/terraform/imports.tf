# imports.tf
# Terraform 1.5+ — importa recursos si no están en el estado

locals {
  account_id     = data.aws_caller_identity.current.id
  logs_arn_base  = "arn:aws:logs:${var.aws_region}:${local.account_id}"
}

import {
  to = aws_kms_key.sri_secrets
  id = "arn:aws:kms::${local.account_id}:alias/sri-secrets"
}

import {
  to = aws_kms_alias.sri_secrets
  id = "alias/sri-secrets"
}

import {
  to = aws_secretsmanager_secret.certificado_p12
  id = "sri/${var.ambiente}/certificado-p12"
}

import {
  to = aws_secretsmanager_secret.certificado_password
  id = "sri/${var.ambiente}/certificado-password"
}

import {
  to = aws_iam_policy.leer_secrets_sri
  id = "arn:aws:iam::${local.account_id}:policy/pol-fact-leer-secrets-sri-${var.ambiente}"
}

import {
  to = aws_iam_policy.lambda_logs_sri
  id = "arn:aws:iam::${local.account_id}:policy/pol-fact-logs-lambda-sri-${var.ambiente}"
}

import {
  to = aws_iam_policy.lambda_s3_sri
  id = "arn:aws:iam::${local.account_id}:policy/pol-fact-s3-lambda-sri-${var.ambiente}"
}

import {
  to = aws_iam_policy.lambda_sqs_sri
  id = "arn:aws:iam::${local.account_id}:policy/pol-fact-sqs-lambda-sri-${var.ambiente}"
}

import {
  to = aws_iam_role.lambda_sri
  id = "rol-fact-lambda-sri-${var.ambiente}"
}

# Cola SQS principal
import {
  to = aws_sqs_queue.cola_sri
  id = "https://sqs.${var.aws_region}.amazonaws.com/${local.account_id}/cola-fact-sri-${var.ambiente}"
}

# Cola SQS muerta (DLQ)
import {
  to = aws_sqs_queue.cola_sri_muerta
  id = "https://sqs.${var.aws_region}.amazonaws.com/${local.account_id}/cola-fact-sri-muerta-${var.ambiente}"
}
