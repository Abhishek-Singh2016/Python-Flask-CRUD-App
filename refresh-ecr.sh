#!/bin/bash
set -e # Exit on any error

# Variables expected from environment: 
# TARGET_ROLE_ARN, REGION, SECRET_NAME, TARGET_NAMESPACE
TARGET_ROLE_ARN="arn:aws:iam::702175642104:role/ecr-image-push"
SECRET_NAME="ecr-pull-image-secret"
REGION="us-east-1"
#TARGET_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
TARGET_NAMESPACE="default"

echo "Assuming IAM Role: $TARGET_ROLE_ARN"
JSON_OUT=$(aws sts assume-role \
  --role-arn "$TARGET_ROLE_ARN" \
  --role-session-name "K8sRefreshSession")

echo $JSON_OUT

# Parse credentials using sed
export AWS_ACCESS_KEY_ID=$(echo $JSON_OUT | sed -n 's/.*"AccessKeyId": "\([^"]*\)".*/\1/p')
export AWS_SECRET_ACCESS_KEY=$(echo $JSON_OUT | sed -n 's/.*"SecretAccessKey": "\([^"]*\)".*/\1/p')
export AWS_SESSION_TOKEN=$(echo $JSON_OUT | sed -n 's/.*"SessionToken": "\([^"]*\)".*/\1/p')

echo "Fetching ECR Login Token for $REGION..."
ECR_PASSWORD=$(aws ecr get-login-password --region "$REGION")

echo "Updating Kubernetes Secret: $SECRET_NAME in $TARGET_NAMESPACE"
kubectl create secret docker-registry "$SECRET_NAME" \
  --docker-server="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com" \
  --docker-username=AWS \
  --docker-password="$ECR_PASSWORD" \
  --namespace "$TARGET_NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "ECR credentials refreshed successfully at $(date)"