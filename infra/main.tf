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
}


# Subnets

resource "aws_subnet" "private_subnet-a" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet-b" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet-c" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2c"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public_subnet-a" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet-b" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet-c" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "eu-west-2c"
  map_public_ip_on_launch = true
}

# Subnet group
resource "aws_db_subnet_group" "private_subnet_group" {
  name = "private_subnet_group"
  description = "Private subnets group for our db"
  subnet_ids = [aws_subnet.private_subnet-a.id, aws_subnet.private_subnet-b.id, aws_subnet.private_subnet-c.id]
}


# Internet Gateway
resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
}

# Create an Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
}

## NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id = aws_subnet.public_subnet-a.id

  tags = {
    Name = "Nat gateway"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_subnet-a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_subnet-b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_c" {
  subnet_id      = aws_subnet.public_subnet-c.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id

  route {
    cidr_block = "10.0.0.0/16"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id      = aws_subnet.private_subnet-a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id      = aws_subnet.private_subnet-b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_c" {
  subnet_id      = aws_subnet.private_subnet-c.id
  route_table_id = aws_route_table.private_route_table.id
}



# Security groups

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "rds_sg"
  description = "RDS Security Group"
  # Inbound: Allows MySQL (3306) traffic only from the EC2 instances' security group.
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  # Outbound: Allows all outbound traffic to the EC2 instances' security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "ec2_sg"
  description = "EC2 Security Group - allow HTTP traffic from ELB security group"
  # Inbound: Allows HTTP (80) traffic only from the Load Balancer's security group.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound: Allows all outbound traffic to the RDS security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "lb_sg"
  description = "Load Balancer Security Group - allow incoming HTTP traffic from the internet"
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

resource "aws_security_group" "pipe_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "pipe_sg"
  description = "Pipeline EC2 Security Group - allow HTTP, ssh and tcp 8080 for Jenkins"
  # Inbound: Allows HTTP (80) traffic from anywhere
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound: Allows all outbound traffic to the RDS security group.
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
  db_name              = "agile_ninjas"
  username             = "root"
  password             = var.rds_password
  db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
  multi_az             = true # Enable multi-AZ deployment
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id, aws_security_group.pipe_sg.id]
}


# Data block to fetch RDS endpoint
data "aws_db_instance" "data-rds" {
  db_instance_identifier = aws_db_instance.agile-ninjas-rds-db.id
}

# EC2 template
resource "aws_launch_template" "web-app-template" {
  name_prefix   = "web-app-lt-"
  image_id      = "ami-028eb925545f314d6"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = base64encode(templatefile("${path.module}/init.tpl",
    {
      db_endpoint   = data.aws_db_instance.data-rds.endpoint,
      rds_user      = var.rds_user,
      rds_password  = var.rds_password,
    }
  ))
}


# Auto Scaling Group
resource "aws_autoscaling_group" "auto-scaling-group" {
  name                 = "auto-scaling-group"
#  launch_configuration = aws_launch_template.web-app-template.name
  launch_template {
    id = aws_launch_template.web-app-template.id
    version = "$Latest"  # You can specify a specific version if needed
  }
  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  vpc_zone_identifier  = [aws_subnet.private_subnet-a.id, aws_subnet.private_subnet-b.id, aws_subnet.private_subnet-c.id]
  health_check_type    = "ELB"
  health_check_grace_period = 300  # 5 minutes grace period
  # Attach the ASG to the ALB target group
  target_group_arns = [aws_lb_target_group.lb-target-group.arn]
}


# Application Load Balancer
resource "aws_lb" "app-load-balancer" {
  name = "app-load-balancer"
#  internal = false
  load_balancer_type = "application"
  subnets = [aws_subnet.public_subnet-a.id, aws_subnet.public_subnet-b.id, aws_subnet.public_subnet-c.id]
  security_groups = [aws_security_group.lb_sg.id]
}

# Load balancer target group
resource "aws_lb_target_group" "lb-target-group" {
  name        = "lb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.agile_ninjas_VPC.id
  target_type = "instance"
}

# Load balancer listener
resource "aws_lb_listener" "load-balancer-listener" {
  load_balancer_arn = aws_lb.app-load-balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }
}


# Pipeline EC2
resource "aws_instance" "pipeline-ec2" {
  subnet_id = aws_subnet.public_subnet-a.id
  ami      = "ami-028eb925545f314d6"
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.pipe_sg.id]
  user_data = base64encode(templatefile("${path.module}/pipeinit.tpl",
    {
      db_endpoint   = data.aws_db_instance.data-rds.endpoint,
      rds_user      = var.rds_user,
      rds_password  = var.rds_password,
    }
  ))
  tags = {
    Name = "pipeline-instance"
  }
  depends_on = [aws_db_instance.agile-ninjas-rds-db]
}