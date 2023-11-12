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
variable "environment" {
  default = "dev"
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  #  you can provide access and secret keys via terminal as an environment var rather than doing it here.
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  # default tags, more info here: https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider
  default_tags {
    tags = {
      project     = var.project
      environment = var.environment
    }
  }
}


# VPC
resource "aws_vpc" "agile_ninjas_VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "agile_ninjas_vpc"
  }
}


# Subnets

# for each loops block for the subnets
# or count, but use for each, because count can be problematic

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.agile_ninjas_VPC.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "agile_ninjas_private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.agile_ninjas_VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false
  tags = {
    Name = "agile_ninjas_private_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id                  = aws_vpc.agile_ninjas_VPC.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false
  tags = {
    Name = "agile_ninjas_private_subnet_c"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.agile_ninjas_VPC.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "agile_ninjas_public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.agile_ninjas_VPC.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "agile_ninjas_public_subnet_b"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.agile_ninjas_VPC.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "agile_ninjas_public_subnet_c"
  }
}

# Subnet group
resource "aws_db_subnet_group" "private_subnet_group" {
  name        = "private_subnet_group"
  description = "Private subnets group for our db"
  subnet_ids  = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id, aws_subnet.private_subnet_c.id]
  tags = {
    Name = "agile_ninjas_private_subnet_group"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  tags = {
    Name = "agile_ninjas_public_igw"
  }
}

# Create an Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  tags = {
    Name = "agile_ninjas_nat_gateway_eip"
  }
}

## NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "agile_ninjas_nat_gateway"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local" # Route traffic within the VPC locally
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }

  tags = {
    Name = "agile_ninjas_public_route_table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local" # Route traffic within the VPC locally
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "agile_ninjas_private_route_table"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_route_table.id
}


# Security groups
resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.agile_ninjas_VPC.id
  name        = "rds_sg"
  description = "RDS Security Group"
  # Inbound: Allows MySQL (3306) traffic only from the EC2 instances' security group.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.pipe_sg.id]
  }
  # Outbound: Allows all outbound traffic to the EC2 instances' security group.
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ec2_sg.id]
  }
  tags = {
    Name = "agile_ninjas_rds_sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id      = aws_vpc.agile_ninjas_VPC.id
  name        = "ec2_sg"
  description = "EC2 Security Group - allow HTTP traffic from ELB security group"
  # Inbound: Allows HTTP (80) traffic only from the Load Balancer's security group.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  # Outbound: Allows all outbound traffic to the RDS security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "agile_ninjas_ec2_sg"
  }
}

resource "aws_security_group" "lb_sg" {
  vpc_id      = aws_vpc.agile_ninjas_VPC.id
  name        = "lb_sg"
  description = "Load Balancer Security Group - allow incoming HTTP traffic from the internet"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "agile_ninjas_lb_sg"
  }
}

resource "aws_security_group" "pipe_sg" {
  vpc_id      = aws_vpc.agile_ninjas_VPC.id
  name        = "pipe_sg"
  description = "Pipeline EC2 Security Group - allow HTTP, ssh and tcp 8080 for Jenkins"
  # Inbound: Allows HTTP (80) traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # this should be set to your own and trusted IP address
  }
  # for Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # this should be set to your own and trusted IP address
  }
  # for Grafana connection
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # for Prometheus connection
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # for ssh connection
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
  tags = {
    Name = "agile_ninjas_pipe_sg"
  }
}


# RDS
resource "aws_db_instance" "agile_ninjas_rds_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t3.micro"
  db_name                = "agile_ninjas"
  username               = "root"
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.private_subnet_group.name
  multi_az               = true # Enable multi-AZ deployment
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id, aws_security_group.pipe_sg.id]
  tags = {
    Name = "agile_ninjas_rds_db"
  }
}


# Data block to fetch RDS endpoint
data "aws_db_instance" "data_rds" {
  db_instance_identifier = aws_db_instance.agile_ninjas_rds_db.id
}

# EC2 template
resource "aws_launch_template" "web_app_template" {
  name_prefix            = "web-app-lt-"
  image_id               = "ami-028eb925545f314d6"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = base64encode(templatefile("${path.module}/init.tpl",
    {
      # remove port number in case it's attached to the endpoint
      db_endpoint  = replace(data.aws_db_instance.data_rds.endpoint, ":3306", ""),
      rds_user     = var.rds_user,
      rds_password = var.rds_password,
    }
  ))
  tags = {
    Name = "agile_ninjas_web_app_launch_template"
  }
  # Specify the dependency on the pipeline-ec2 - we need our table in RDS to be initialised thanks to the user_data script in the pipe-ec2
  depends_on = [aws_instance.pipeline_ec2]
}


# Auto Scaling Group
resource "aws_autoscaling_group" "auto_scaling_group" {
  name = "agile_ninjas_auto_scaling_group"
  launch_template {
    id      = aws_launch_template.web_app_template.id
    version = "$Latest" # You can specify a specific version if needed
  }
  min_size                  = 1
  desired_capacity          = 1
  max_size                  = 1
  vpc_zone_identifier       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id, aws_subnet.private_subnet_c.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300 # 5 minutes grace period
  # Attach the ASG to the ALB target group
  target_group_arns = [aws_lb_target_group.lb_target_group.arn]
}


# Application Load Balancer
resource "aws_lb" "app_load_balancer" {
  name = "app-load-balancer"
  #  internal = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.public_subnet_c.id]
  security_groups    = [aws_security_group.lb_sg.id]
}

# Load balancer target group
resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.agile_ninjas_VPC.id
  target_type = "instance"
}

# Load balancer listener
resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  tags = {
    Name = "agile_ninjas_load_balancer_listener"
  }
}


# Pipeline EC2
resource "aws_instance" "pipeline_ec2" {
  subnet_id              = aws_subnet.public_subnet_b.id
  ami                    = "ami-028eb925545f314d6"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.pipe_sg.id]
  # in future the set up and installation of tools should be cooked using Ansible, for now this is a 'smart' work around
  user_data = base64encode(templatefile("${path.module}/pipeinit.tpl",
    {
      db_endpoint  = replace(data.aws_db_instance.data_rds.endpoint, ":3306", ""), # there is a way to call the endpoint directly without creating data resource
      rds_user     = var.rds_user,
      rds_password = var.rds_password,
      lb_dns_name  = aws_lb.app_load_balancer.dns_name,
    }
  ))
  tags = {
    Name = "agile_ninjas_pipeline-instance"
  }
  depends_on = [aws_db_instance.agile_ninjas_rds_db]
}