# VPC

This Terraform Deploys VPC

## USAGE

terraform init

terraform apply -auto-approve

The following values are required for the terraform to function properly.
1. **aws-region**: The AWS region where you want to deploy.
2. **aws-profile**: A profile that includes the account credentials.
3. **project-name**: Project name
4. **environment-name**: Environment name e.g. test, prod, qa, uat, etc.

