variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "eu-west-2"
}
variable "rds_user" {}
variable "rds_password" {}
variable "project" {
  default = "quizlet"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}


# VPC
resource "aws_vpc" "agile_ninjas_VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "agile-ninjas-vpc"
    Project = var.project
  }
}


# Subnets

resource "aws_subnet" "private_subnet-a" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = false
  tags {
    Name = "private-subnet-a"
    Project = var.project
  }
}

resource "aws_subnet" "private_subnet-b" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = false
  tags {
    Name = "private-subnet-b"
    Project = var.project
  }
}

resource "aws_subnet" "private_subnet-c" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2c"
  map_public_ip_on_launch = false
  tags {
    Name = "private-subnet-c"
    Project = var.project
  }
}


# Subnet group
resource "aws_db_subnet_group" "private_subnet_group" {
  name = "private_subnet_group"
  subnet_ids = [aws_subnet.private_subnet-a.id, aws_subnet.private_subnet-b.id, aws_subnet.private_subnet-c.id]
  tags {
    Name = "private-subnet-group"
    Project = var.project
  }
}


# Security groups

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "rds_sg"
  description = "RDS Security Group"
  tags {
    Name = "rds-security-group"
    Project = var.project
  }
  # Inbound: Allows MySQL (3306) traffic only from the EC2 instances' security group.
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = aws_security_group.ec2_sg.id
  }
  # Outbound: Allows all outbound traffic to the EC2 instances' security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
    security_groups = aws_security_group.ec2_sg.id
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "ec2_sg"
  description = "EC2 Security Group"
  tags {
    Name = "web-app-sg"
    Project = var.project
  }
  # Inbound: Allows HTTP (80) traffic only from the Load Balancer's security group.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = aws_security_group.lb_sg.id
  }
  # Outbound: Allows all outbound traffic to the RDS security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
    security_groups = aws_security_group.ec2_sg.id
  }
}

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "lb_sg"
  description = "Load Balancer Security Group"
  tags {
    Name = "lb-sg"
    Project = var.project
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# RDS
resource "aws_db_instance" "agile-ninjas-rds-db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = "db.t3.micro"
  username             = "root"
  password             = var.rds_password
  db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
  multi_az             = true # Enable multi-AZ deployment
  tags {
    Name = "web-app-rds"
    Project = var.project
  }
}

# Data block to fetch RDS endpoint
data "aws_db_instance" "data-rds" {
  db_instance_identifier = aws_db_instance.agile-ninjas-rds-db.id
}

# EC2 template
resource "aws_launch_configuration" "web-app-template" {
  name_prefix   = "web-app-lc-"
  image_id      = "ami-028eb925545f314d6"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # This script initializes the EC2 instance for the web application.

              # Redirect script output to log file
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              # Update the instance
              yum update -y

              # Install Docker
              yum install -y docker
              service docker start

              # Pull and run the Docker container
              docker pull weronikadocker/agile-ninjas-project
              docker run -d -p 80:5000 \
                -e MYSQL_DATABASE_HOST=${data.aws_db_instance.data-rds.endpoint} \
                -e MYSQL_DATABASE_USER=${var.rds_user} \
                -e MYSQL_DATABASE_PASSWORD=${var.rds_password} \
                weronikadocker/agile-ninjas-project
              EOF
  tags {
    Name = "web-app"
    Project = var.project
  }
}
# note on the User Data above: In this code, ${data.aws_db_instance.data-rds.endpoint} fetches the RDS instance's
# endpoint (host) dynamically, and your EC2 instance will connect to the RDS instance without specifying a database name
# in the user_data script.


# Auto Scaling Group
resource "aws_autoscaling_group" "auto-scaling-group" {
  name                 = "auto-scaling-group"
  launch_configuration = aws_launch_configuration.web-app-template.name
  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  vpc_zone_identifier  = [aws_subnet.private_subnet-a.id, aws_subnet.private_subnet-b.id, aws_subnet.private_subnet-c.id]
  health_check_type    = "ELB"
  health_check_grace_period = 300  # 5 minutes grace period
  cooldown = 300 # 5 minutes cooldown period
  # Attach the ASG to the ALB target group
  target_group_arns = [aws_lb_target_group.lb-target-group.arn]
  tags {
    Name = "auto-scaling-group"
    Project = var.project
  }
}


# Application Load Balancer
resource "aws_lb" "app-load-balancer" {
  name = "app-load-balancer"
  internal = false
  load_balancer_type = "application"
  subnets = [aws_subnet.private_subnet-a.id, aws_subnet.private_subnet-b.id, aws_subnet.private_subnet-c.id]
  tags {
    Name = "app-load-balancer"
    Project = var.project
  }
}

# Load balancer target group
resource "aws_lb_target_group" "lb-target-group" {
  name        = "lb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.agile_ninjas_VPC.id
  target_type = "instance"
  tags {
    Name = "lb-target-group"
    Project = var.project
  }
}

# Load balancer listener
resource "aws_lb_listener" "load-balancer-listener" {
  load_balancer_arn = aws_lb.app-load-balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      content      = "OK"
    }
  }
  tags {
    Name = "lb-listener"
    Project = var.project
  }
}
