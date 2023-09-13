# Grafana

This Terraform Deploys Grafana

#### USAGE

terraform init

terraform apply -auto-approve

The following values are required for the terraform to function properly.
1. **aws-region**: The AWS region where you want to deploy.
2. **aws-profile**: A profile that includes the account credentials.
3. **create-key**: If you want to create a new key, type "y," otherwise "n." NOTE: Only lowercase y and n are acceptable.
4. **ec2-key**: Enter the name of the key to be used with the Grafna instance.
5. **project-name**: Project name
6. **environment-name**: Environment name e.g. test, prod, qa, uat, etc.
7. **vpc-id**: The VPC ID in which the instance will be created.
8. **subnet-id**: the subnet id in which the instance will be created.
9. **iam-role**: iam-role with cloudwatch fullacess arn should be associated with an EC2 instance. If not previously created, leave empty to create a new one otherwise enter the role arn.
10. **instance-type**: t2.micro will suffice.
