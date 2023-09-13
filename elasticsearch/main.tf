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

data "aws_subnets" "vpc-subnet" {
  filter {
    name   = "tag:Name"
    values = ["*${var.connectivity}*"] # insert values here
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc-id]
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

resource "aws_security_group" "elasticsearch-security-group" {
  name   = "${var.environment-name}-elasticsearch-${var.project-name}"
  vpc_id = var.vpc-id

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.connectivity == "public" ? var.antier_ips : [var.vpc-cidr]
    from_port   = "22"
    to_port     = "22"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.connectivity == "public" ? var.antier_ips : [var.vpc-cidr]
    from_port   = "9200"
    to_port     = "9200"
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = var.connectivity == "public" ? var.antier_ips : [var.vpc-cidr]
    from_port   = "5601"
    to_port     = "5601"
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
    Name = "${var.environment-name}-elasticsearch-${var.project-name}"
  }
}


resource "aws_instance" "elasticsearch_instance" {
  depends_on = [
    aws_security_group.elasticsearch-security-group
  ]
  count                   = var.node-count
  ami                     = data.aws_ami.ubuntu-20.image_id
  instance_type           = var.instance_type
  key_name                = var.ec2-key
  subnet_id               = tolist(data.aws_subnets.vpc-subnet.ids)[count.index % length(data.aws_subnets.vpc-subnet.ids)]
  disable_api_termination = true
  monitoring              = true
  vpc_security_group_ids  = [aws_security_group.elasticsearch-security-group.id]
  tags = {
    Name = "${var.environment-name}-elasticsearch-${count.index + 1}-${var.project-name}"
  }
}

resource "aws_eip" "elasticsearch_eip" {
  count = var.connectivity == "public" ? var.node-count : 0
  depends_on = [
    aws_instance.elasticsearch_instance
  ]
  instance = aws_instance.elasticsearch_instance[count.index].id
  tags = {
    Name = "${var.environment-name}-elasticsearch-${count.index + 1}-${var.project-name}"
  }
}

resource "null_resource" "install_elasticsearch" {
  count = var.node-count
  connection {
    type        = "ssh"
    host        = var.connectivity == "public" ? aws_eip.elasticsearch_eip[count.index].public_ip : aws_instance.elasticsearch_instance[count.index].private_ip
    user        = "ubuntu"
    port        = "22"
    private_key = file("${var.ec2-key}.pem")
  }

  provisioner "file" {
    source      = "install_elasticsearch.sh"
    destination = "/home/ubuntu/install_elasticsearch.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/install_elasticsearch.sh demo-cluster es${count.index + 1} ${"[\\'${join("\\',\\'", aws_instance.elasticsearch_instance.*.private_ip)}\\']"} ${"[\\'${join("\\',\\'", [for i in range(var.node-count) : "es${i + 1}"])}\\']"}",
    ]
  }
}


