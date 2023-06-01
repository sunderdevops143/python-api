#!/bin/bash

# Set your AWS region
AWS_REGION="us-east-1"

# Set your ECR repository details
ECR_REPOSITORY_NAME="flask_app_repo"
DOCKER_IMAGE_TAG="latest"

# Set your health check endpoint
HEALTH_CHECK_ENDPOINT="http://http://127.0.0.1/:5000/health"

# Build the Docker image
echo "Building Docker image..."
docker build -t $ECR_REPOSITORY_NAME:$DOCKER_IMAGE_TAG .

# Authenticate Docker with ECR
echo "Authenticating Docker with ECR..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY_URI

# Create the ECR repository if it doesn't exist
echo "Creating ECR repository..."
aws ecr describe-repositories --repository-names $ECR_REPOSITORY_NAME > /dev/null 2>&1
if [ $? -ne 0 ]; then
    aws ecr create-repository --repository-name $ECR_REPOSITORY_NAME > /dev/null
fi

# Push the Docker image to ECR
echo "Pushing Docker image to ECR..."
docker tag $ECR_REPOSITORY_NAME:$DOCKER_IMAGE_TAG $ECR_REGISTRY_URI/$ECR_REPOSITORY_NAME:$DOCKER_IMAGE_TAG
docker push $ECR_REGISTRY_URI/$ECR_REPOSITORY_NAME:$DOCKER_IMAGE_TAG

# Perform a health check
echo "Performing health check..."
HEALTH_CHECK_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_CHECK_ENDPOINT)
if [ $HEALTH_CHECK_STATUS -eq 200 ]; then
    echo "Health check passed! Deployment successful."
else
    echo "Health check failed. Deployment unsuccessful."
fi
