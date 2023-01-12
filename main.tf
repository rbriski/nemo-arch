variable "key_pair" {
  type = object({
    name = string
    key  = string
  })
  sensitive = true
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["dept-nemo-image-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["367809009760"]
}

resource "aws_vpc" "ml_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ML VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.ml_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Public ML Subnet"
  }
}

resource "aws_internet_gateway" "ml_vpc_igw" {
  vpc_id = aws_vpc.ml_vpc.id

  tags = {
    Name = "ML VPC - Internet Gateway"
  }
}

resource "aws_route_table" "ml_vpc_us_west_2a_public" {
  vpc_id = aws_vpc.ml_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ml_vpc_igw.id
  }

  tags = {
    Name = "ML Public Subnet Route Table."
  }
}

resource "aws_route_table_association" "ml_vpc_us_west_2a_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.ml_vpc_us_west_2a_public.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound connections"
  vpc_id      = aws_vpc.ml_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_sg"
  }
}

resource "aws_key_pair" "bbriski" {
  key_name   = var.key_pair.name
  public_key = var.key_pair.key
}

resource "aws_instance" "ml" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "p3.2xlarge"
  key_name                    = aws_key_pair.bbriski.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 100 # in GB <<----- I increased this!
    volume_type = "gp2"
    encrypted   = false
  }

  tags = {
    name = "question-answering"
  }
}


output "instance_ip_addr" {
  value = aws_instance.ml.public_ip
}
