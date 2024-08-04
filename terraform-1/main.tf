terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57.0"
    }
  }
  required_version = ">= 1.3.0, <= 1.9.2"
}

data "aws_vpc" "main" {
  id = "vpc-03a6b0825cdc0ea33"
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                   = data.aws_vpc.main.id
  cidr_block               = "172.31.32.0/20"
  map_public_ip_on_launch  = true
}

# Create private subnets
resource "aws_subnet" "private1" {
  vpc_id             = data.aws_vpc.main.id
  cidr_block         = "172.31.64.0/20"
  availability_zone  = "ap-southeast-1a"
}

resource "aws_subnet" "private2" {
  vpc_id             = data.aws_vpc.main.id
  cidr_block         = "172.31.80.0/20"
  availability_zone  = "ap-southeast-1b"
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.main.id
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group allowing SSH and HTTP access
resource "aws_security_group" "example" {
  vpc_id      = data.aws_vpc.main.id
  name_prefix = "example-"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Frontend instance
resource "aws_instance" "frontend" {
  ami                         = "ami-060e277c0d4cce553"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  key_name                    = "abhishek-1"
  security_groups             = [aws_security_group.example.id]
  associate_public_ip_address = true

  tags = {
    Name = "FRONTEND"
  }

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/abhi/abhishek-1.pem")
      host        = self.public_ip
      timeout     = "10m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/frontend.sh",
      "/tmp/frontend.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/abhi/abhishek-1.pem")
      host        = self.public_ip
      timeout     = "10m"
    }
  }
}

# Backend instance
resource "aws_instance" "backend" {
  ami           = "ami-060e277c0d4cce553"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private1.id
  key_name      = "abhishek-1"
  security_groups = [aws_security_group.example.id]

  tags = {
    Name = "BACKEND"
  }

  provisioner "file" {
    source      = "backend.sh"
    destination = "/tmp/backend.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/abhi/abhishek-1.pem")
      host        = self.private_ip
      timeout     = "10m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/backend.sh",
      "/tmp/backend.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/abhi/abhishek-1.pem")
      host        = self.private_ip
      timeout     = "10m"
    }
  }
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}
