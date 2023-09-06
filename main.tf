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
  // Add inbound and outbound rules as needed for your RDS access.
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.agile_ninjas_VPC.id
  name = "ec2_sg"
  description = "EC2 Security Group"
  tags {
    Name = "web-app-sg"
    Project = var.project
  }
  // Add inbound rules as needed for your application.
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
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              yum update -y
              yum install -y docker
              service docker start
              docker pull weronikadocker/agile-ninjas-project
              docker run -d -p 80:5000 -e MYSQL_DATABASE_HOST=${data.aws_db_instance.data-rds.endpoint} -e MYSQL_DATABASE_USER=${var.rds_user} -e MYSQL_DATABASE_PASSWORD=${var.rds_password} weronikadocker/agile-ninjas-project
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
resource "aws_autoscaling_group" "example" {
  name                 = "example-asg"
  launch_configuration = aws_launch_configuration.web-app-template.name
  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  vpc_zone_identifier  = aws_subnet.private_subnets[*].id
  // Add other Auto Scaling Group settings as needed.
}


#resource "aws_internet_gateway" "example" {
#  vpc_id = aws_vpc.agina_ninjas_VPC.id
#  tags = {
#    Name = "example-igw"
#  }
#}
#
#resource "aws_route_table" "example" {
#  vpc_id = aws_vpc.agina_ninjas_VPC.id
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.example.id
#  }
#  tags = {
#    Name = "example-rt"
#  }
#}
#
#resource "aws_route_table_association" "subnet_association" {
#  count          = 2
#  subnet_id      = aws_subnet.subnet_a[count.index].id
#  route_table_id = aws_route_table.example.id
#}
#
#resource "aws_instance" "web" {
#  count         = 2
#  ami           = "ami-028eb925545f314d6"
#  instance_type = "t2.micro"
#  subnet_id     = aws_subnet.subnet_a[count.index].id
#  tags = {
#    Name = "app-server"
#  }
#}
#
#resource "aws_security_group" "example" {
#  name        = "example-sg"
#  description = "Example security group"
#  vpc_id      = aws_vpc.agina_ninjas_VPC.id
#
#  egress {
#    from_port   = 0
#    to_port     = 65535
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
#resource "aws_security_group_rule" "egress" {
#  type        = "egress"
#  from_port   = 0
#  to_port     = 65535
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.example.id
#}
#
#resource "aws_security_group_rule" "ingress" {
#  type        = "ingress"
#  from_port   = 80
#  to_port     = 80
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.example.id
#}
#
#resource "aws_nat_gateway" "example" {
#  allocation_id = aws_eip.example.id
#  subnet_id     = aws_subnet.subnet_a[0].id # Use the public subnet in one AZ
#}
#
#resource "aws_eip" "example" {
#  count = 2
#}
#
#resource "aws_launch_configuration" "example" {
#  name_prefix          = "example-lc-"
#  image_id             = "ami-028eb925545f314d6" # Your desired AMI
#  instance_type        = "t2.micro"
#  security_groups      = [aws_security_group.example.name]
#  user_data            = file("user_data.sh")
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
#resource "aws_autoscaling_group" "example" {
#  launch_configuration = aws_launch_configuration.example.name
#  availability_zones  = aws_subnet.subnet_a[*].availability_zone
#  target_group_arns   = [aws_lb_target_group.example.arn]
#  min_size            = 2
#  max_size            = 2
#  desired_capacity    = 2
#  vpc_zone_identifier = aws_subnet.subnet_a[*].id
#
#  tag {
#    key                 = "Name"
#    value               = "app-server"
#    propagate_at_launch = true
#  }
#}
#
#resource "aws_lb" "example" {
#  name               = "example-lb"
#  internal           = false
#  load_balancer_type = "application"
#  security_groups    = [aws_security_group.example.id]
#  subnets            = aws_subnet.subnet_a[*].id
#}
#
#resource "aws_lb_target_group" "example" {
#  name     = "example-tg"
#  port     = 80
#  protocol = "HTTP"
#  vpc_id   = aws_vpc.example.id
#}
#
#resource "aws_lb_listener" "example" {
#  load_balancer_arn = aws_lb.example.arn
#  port              = 80
#  protocol          = "HTTP"
#
#  default_action {
#    type             = "fixed-response"
#    fixed_response {
#      content_type = "text/plain"
#      status_code  = "200"
#      content      = "OK"
#    }
#  }
#}
#
#
#provider "aws" {
#  access_key = var.aws_access_key
#  secret_key = var.aws_secret_key
#  region     = var.aws_region
#}
#
#resource "aws_instance" "web" {
#  count	= "2"
#  ami = "ami-028eb925545f314d6"
#  instance_type = "t2.micro"
#  tags = {
#    Name = "W-webserver1"
#    location = "UK"
#    identity = "Weronika"
#  }
#}
#
#
#

