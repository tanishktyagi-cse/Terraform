provider "aws" {
  region  = var.aws-region
  profile = var.aws-profile
}

data "aws_ami" "ubuntu-20" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230328"]
  }
}

module "key_pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  key_name           = "${var.environment-name}-ovpn-${var.project-name}"
  create_private_key = true
}

resource "local_file" "private_key" {
  content  = module.key_pair.private_key_pem
  filename = "${var.environment-name}-ovpn-${var.project-name}.pem"
  provisioner "local-exec" {
    command = "chmod 400 ${var.environment-name}-ovpn-${var.project-name}.pem"
  }
}

resource "aws_security_group" "ovpn-security-group" {
  name   = "${var.environment-name}-ovpn-${var.project-name}"
  vpc_id = var.vpc-id

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["112.196.25.234/32", "182.73.149.42/32", "112.196.81.250/32", "125.21.216.158/32"]
    from_port   = "0"
    to_port     = "65535"
  }

  ingress {
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "1194"
    to_port     = "1194"
  }

  ingress {
    protocol    = "-1"
    cidr_blocks = [var.vpc-cidr]
    from_port   = "0"
    to_port     = "0"
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
  }

  tags = {
    Name = "${var.environment-name}-ovpn-${var.project-name}"
  }
}

resource "aws_instance" "ovpn_instance" {
  depends_on = [
    aws_security_group.ovpn-security-group
  ]
  ami                     = data.aws_ami.ubuntu-20.image_id
  instance_type           = var.instance_type
  key_name                = module.key_pair.key_pair_name
  subnet_id               = var.subnet-id
  disable_api_termination = true
  vpc_security_group_ids  = [aws_security_group.ovpn-security-group.id]
  tags = {
    Name = "${var.environment-name}-ovpn-${var.project-name}"
  }
}

resource "aws_eip" "ovpn_eip" {
  depends_on = [
    aws_instance.ovpn_instance
  ]
  instance = aws_instance.ovpn_instance.id
  tags = {
    Name = "${var.environment-name}-ovpn-${var.project-name}"
  }
}

resource "null_resource" "install_ovpn" {
  triggers = {
    public_ip = aws_eip.ovpn_eip.public_ip
  }

  connection {
    type        = "ssh"
    host        = aws_eip.ovpn_eip.public_ip
    user        = "ubuntu"
    port        = "22"
    private_key = file("${var.environment-name}-ovpn-${var.project-name}.pem")
  }

  provisioner "file" {
    source      = "install_ovpn.sh"
    destination = "/home/ubuntu/install_ovpn.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/install_ovpn.sh",
    ]
  }
}


