#!/bin/bash
# verificar_recursos.sh
AMBIENTE="certificacion"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"

echo "=== Lambdas ==="
aws lambda list-functions \
  --query 'Functions[*].FunctionName' \
  --output text --region $REGION

echo "=== Políticas IAM ==="
aws iam list-policies --scope Local \
  --query 'Policies[*].PolicyName' \
  --output text

echo "=== Roles IAM ==="
aws iam list-roles \
  --query 'Roles[?starts_with(RoleName,`rol-fact`)].RoleName' \
  --output text

echo "=== Colas SQS ==="
aws sqs list-queues --region $REGION \
  --output text

echo "=== Secrets ==="
aws secretsmanager list-secrets \
  --query 'SecretList[*].Name' \
  --output text --region $REGION

echo "=== KMS Aliases ==="
aws kms list-aliases \
  --query 'Aliases[?starts_with(AliasName,`alias/sri`)].AliasName' \
  --output text --region $REGION

echo "=== CloudWatch Log Groups ==="
aws logs describe-log-groups \
  --log-group-name-prefix /aws/lambda/fact \
  --query 'logGroups[*].logGroupName' \
  --output text --region $REGION

echo "=== API Gateways ==="
aws apigateway get-rest-apis \
  --query 'items[*].{ID:id,Nombre:name}' \
  --output table --region $REGION

echo "=== Cognito User Pools ==="
aws cognito-idp list-user-pools --max-results 10 \
  --query 'UserPools[*].{ID:Id,Nombre:Name}' \
  --output table --region $REGION

echo "=== S3 Buckets ==="
aws s3 ls | grep -E "facturacion|sri|frontend"