# VPC

This Terraform Deploys OVPN

## USAGE

terraform init

terraform apply -auto-approve

The following values are required for the terraform to function properly.
1. **aws-region**: The AWS region where you want to deploy.
2. **aws-profile**: A profile that includes the account credentials.
3. **project-name**: Project name
4. **environment-name**: Environment name e.g. test, prod, qa, uat, etc.
5. **vpc-id**: The VPC ID in which the instance will be created.
6. **subnet-id**: the subnet id in which the instance will be created.
7. **vpc-cidr**: cidr of vpc id entered earlier
8. **instance-type**: t2.small will suffice.

