data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# IAM Resources
resource "aws_iam_role" "ec2_role" {
  name = "EC2AutomationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2AutomationProfile"
  role = aws_iam_role.ec2_role.name
}

# Networking
resource "aws_vpc" "assignment_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "assignment-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.assignment_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.assignment_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.assignment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.assignment_vpc.id

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

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  user_data              = templatefile("${path.module}/user_data.sh.tftpl", {
    stage     = var.stage
    repo_url  = var.repo_url
    stop_time = var.stop_time
  })

  tags = {
    Name  = "AppServer-${var.stage}"
    Stage = var.stage
  }
}