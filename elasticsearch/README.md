# VPC

This Terraform Deploys ElasticSearch. Can create both a single node or cluster of nodes

## USAGE

terraform init

terraform apply -auto-approve

The following values are required for the terraform to function properly.
1. **aws-region**: The AWS region where you want to deploy.
2. **aws-profile**: A profile that includes the account credentials.
3. **create-key**: If you want to create a new key, type "y," otherwise "n." NOTE: Only lowercase y and n are acceptable.
4. **ec2-key**: Enter the name of the key to be used with the instance.
5. **project-name**: Project name
6. **environment-name**: Environment name e.g. test, prod, qa, uat, etc.
7. **vpc-id**: The VPC ID in which the instance will be created.
8. **vpc-cidr**: cidr of vpc id entered earlier
9. **instance-type**: t3.medium will suffice.
10. **connectivity**: Make node public or private. NOTE: Only lowercase public and private are acceptable.
11. **node-count**: Enter the number of nodes to be created. If more than 1 enter then it will create a cluster of nodes in different AZ's

