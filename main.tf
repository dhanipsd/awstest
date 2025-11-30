terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
# SSH Key Pair
# -----------------------------
resource "aws_key_pair" "node_key" {
  key_name   = "nodeapp-key"
  public_key = file(var.public_key_path)
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "node_sg" {
  name        = "nodeapp-sg"
  description = "Allow HTTP/HTTPS/SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# EC2 (CentOS 7)
# -----------------------------
resource "aws_instance" "node" {
  ami                    = var.centos7_ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.node_key.key_name
  vpc_security_group_ids = [aws_security_group.node_sg.id]

  tags = {
    Name = "nodeapp-centos"
  }

  # Upload APP folder
  provisioner "file" {
    source      = "${path.module}/app"
    destination = "/tmp/app"
    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  # Upload Nginx config
  provisioner "file" {
    source      = "${path.module}/nginx/node.conf"
    destination = "/tmp/node.conf"
    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  # Upload systemd service
  provisioner "file" {
    source      = "${path.module}/systemd/nodeapp.service"
    destination = "/tmp/nodeapp.service"
    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  # Run setup script
  provisioner "remote-exec" {
    script = "${path.module}/userdata.sh"

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}
