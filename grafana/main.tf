provider "aws" {
  region  = var.aws-region
  profile = var.aws-profile
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230404.0-x86_64-gp2"]
  }
}

module "key_pair" {
  count              = var.create-key == "y" ? 1 : 0
  source             = "terraform-aws-modules/key-pair/aws"
  key_name           = var.ec2-key
  create_private_key = true
}

resource "local_file" "private_key" {
  count    = var.create-key == "y" ? 1 : 0
  content  = module.key_pair[0].private_key_pem
  filename = "${var.ec2-key}.pem"
}

resource "aws_security_group" "grafana-security-group" {
  name   = "${var.environment-name}-grafana-${var.project-name}"
  vpc_id = var.vpc-id

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["112.196.25.234/32", "182.73.149.42/32", "112.196.81.250/32", "125.21.216.158/32"]
    from_port   = "22"
    to_port     = "22"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["112.196.25.234/32", "182.73.149.42/32", "112.196.81.250/32", "125.21.216.158/32"]
    from_port   = "3000"
    to_port     = "3000"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "587"
    to_port     = "587"
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
  }

  tags = {
    Name = "${var.environment-name}-grafana-${var.project-name}"
  }
}

resource "aws_iam_role" "grafana_role" {
  count = var.iam-role != "" ? 0 : 1
  name  = "Antier-grafana-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "Antier-grafana-role"
  }
}

resource "aws_iam_policy_attachment" "cloudwatch-policy-attach" {
  count      = var.iam-role != "" ? 0 : 1
  depends_on = [aws_iam_role.grafana_role[0]]
  name       = "grafana-cloudwatch-full-access"
  roles      = [aws_iam_role.grafana_role[0].name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_instance_profile" "garfana-instance-profile" {
  name = "grafana_profile"
  role = var.iam-role != "" ? var.iam-role : aws_iam_role.grafana_role[0].name

}

resource "aws_instance" "grafana_instance" {
  depends_on = [
    aws_security_group.grafana-security-group
  ]
  ami           = data.aws_ami.amazon-linux-2.image_id
  instance_type = var.instance_type
  key_name      = var.create-key == "y" ? module.key_pair[0].key_pair_name : var.ec2-key
  subnet_id     = var.subnet-id

  user_data               = file("install_grafana.sh")
  disable_api_termination = true
  iam_instance_profile    = aws_iam_instance_profile.garfana-instance-profile.name
  monitoring              = true
  vpc_security_group_ids  = [aws_security_group.grafana-security-group.id]
  tags = {
    Name = "${var.environment-name}-grafana-${var.project-name}"
  }
}

resource "aws_eip" "grafana_eip" {
  depends_on = [
    aws_instance.grafana_instance
  ]
  instance = aws_instance.grafana_instance.id
  tags = {
    Name = "${var.environment-name}-grafana-${var.project-name}"
  }
}

