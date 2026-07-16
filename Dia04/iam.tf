# -------------------------------------------------
# Rol IAM para la Lambda
# -------------------------------------------------
resource "aws_iam_role" "lambda_sri" {
  name        = "rol-fact-lambda-sri-${var.ambiente}"
  description = "Rol para Lambda de facturacion electronica SRI Ecuador"

  # Permite que Lambda asuma este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaAssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Proyecto = "billingfact"
    Ambiente = var.ambiente
  }

  lifecycle {
    # Si el rol ya existe, no intentar recrearlo
    ignore_changes  = [name, tags]
    prevent_destroy = false
  }  
}

# -------------------------------------------------
# Política: leer secrets del SRI en Secrets Manager
# -------------------------------------------------
resource "aws_iam_policy" "leer_secrets_sri" {
  name        = "pol-fact-leer-secrets-sri-${var.ambiente}"
  description = "Permite a la Lambda leer los secrets del certificado SRI"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LeerSecretsSRI"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.id}:secret:sri/${var.ambiente}/certificado-p12*",
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.id}:secret:sri/${var.ambiente}/certificado-password*"
        ]
      },
      {
        Sid    = "UsarKMSParaDescifrar"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.sri_secrets.arn
        ]
      }
    ]
  })

  tags = {
    Proyecto = "billingfact"
    Ambiente = var.ambiente
  }

  lifecycle {
    # Si el rol ya existe, no intentar recrearlo
    ignore_changes  = [name, tags]
    prevent_destroy = false
  }  
}

# -------------------------------------------------
# Política: escribir logs en CloudWatch
# -------------------------------------------------
resource "aws_iam_policy" "lambda_logs_sri" {
  name        = "pol-fact-logs-lambda-sri-${var.ambiente}"
  description = "Permite a la Lambda escribir logs en CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CrearLogGroup"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup"
        ]
        # Resource = "arn:aws:logs:${var.aws_region}:${aws_caller_identity.current.account_id}:*"
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.id}:log-group:*"
        # Resource = "${local.logs_arn_base}:log-group:*"
      },
      {
        Sid    = "EscribirLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        # Resource = "arn:aws:logs:${var.aws_region}:${aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*"
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/*:log-stream:*"
        # Resource = "${local.logs_arn_base}:log-group:/aws/lambda/*:log-stream:*"
      }
    ]
  })

  tags = {
    Proyecto = "billingfact"
    Ambiente = var.ambiente
  }

  lifecycle {
    # Si el rol ya existe, no intentar recrearlo
    ignore_changes  = [name, tags]
    prevent_destroy = false
  }

}

# -------------------------------------------------
# Política: acceso a S3 para guardar XML y RIDE
# -------------------------------------------------
resource "aws_iam_policy" "lambda_s3_sri" {
  name        = "pol-fact-s3-lambda-sri-${var.ambiente}"
  description = "Permite a la Lambda guardar comprobantes en S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GestionarComprobantes"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_comprobantes}/${var.ambiente}/*"
      },
      {
        Sid    = "ListarBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_comprobantes}"
        Condition = {
          StringLike = {
            "s3:prefix" = ["${var.ambiente}/*"]
          }
        }
      }
    ]
  })

  tags = {
    Proyecto = "billingfact"
    Ambiente = var.ambiente
  }

  lifecycle {
    # Si el rol ya existe, no intentar recrearlo
    ignore_changes  = [name, tags]
    prevent_destroy = false
  }

}

# -------------------------------------------------
# Política: enviar mensajes a SQS (reintentos SRI)
# -------------------------------------------------
resource "aws_iam_policy" "lambda_sqs_sri" {
  name        = "pol-sqs-lambda-sri-${var.ambiente}"
  description = "Permite a la Lambda interactuar con la cola SQS del SRI"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GestionarColaSRI"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.cola_sri.arn
      }
    ]
  })

  tags = {
    Proyecto = "billingfact"
    Ambiente = var.ambiente
  }

  lifecycle {
    # Si el rol ya existe, no intentar recrearlo
    ignore_changes  = [name, tags]
    prevent_destroy = false
  }  

}

# -------------------------------------------------
# Adjuntar todas las políticas al rol
# -------------------------------------------------
resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.lambda_sri.name
  policy_arn = aws_iam_policy.leer_secrets_sri.arn
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda_sri.name
  policy_arn = aws_iam_policy.lambda_logs_sri.arn
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.lambda_sri.name
  policy_arn = aws_iam_policy.lambda_s3_sri.arn
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.lambda_sri.name
  policy_arn = aws_iam_policy.lambda_sqs_sri.arn
}

# -------------------------------------------------
# Data source: obtener el Account ID automaticamente
# -------------------------------------------------
# data "aws_caller_identity" "current" {}
