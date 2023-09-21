#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "aws_region" {
#  default = "eu-west-2"
#}
#variable "rds_user" {}
#variable "rds_password" {}
#
#terraform {
#  required_providers {
#    aws = {
#      source = "hashicorp/aws"
#      version = "~> 5.0"
#    }
#  }
#}
#
#provider "aws" {
#  access_key = var.aws_access_key
#  secret_key = var.aws_secret_key
#  region = var.aws_region
#}
#
## Create an AWS instance
#resource "aws_instance" "agile_app" {
#  ami           = "ami-028eb925545f314d6"
#  instance_type = "t2.micro"
#  tags = {
#    Name = "test-instance"
#  }
#  user_data = <<-EOF
#        #!/bin/bash
#        exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#        yum update -y
#        yum install -y docker
#        service docker start
#        docker pull weronikadocker/agile-ninjas-project:latest
#        docker run -d -p 80:5000 weronikadocker/agile-ninjas-project
#              EOF
#}
#
#
#resource "aws_security_group" "agile_app_sg" {
#  name_prefix = "test-sg-"
#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
#resource "aws_network_interface_sg_attachment" "sg_attachment" {
#  security_group_id    = aws_security_group.agile_app_sg.id
#  network_interface_id = aws_instance.agile_app.primary_network_interface_id
#}
#
#
#
#
#
#
#
#resource "aws_instance" "test_ec2" {
#  image_id      = "ami-028eb925545f314d6"
#  instance_type = "t2.micro"
#  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
##  user_data ="${base64encode("init.sh")}"
#}
#
#resource "aws_security_group" "ec2_sg" {
#  vpc_id = aws_vpc.agile_ninjas_VPC.id
#  name = "ec2_sg"
#  description = "EC2 Security Group"
#  # Inbound: Allows HTTP (80) traffic only from the Load Balancer's security group.
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    security_groups = [aws_security_group.lb_sg.id]
#  }
#  # Outbound: Allows all outbound traffic to the RDS security group.
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
#
## EC2 template
#resource "aws_launch_template" "web-app-template" {
#  name_prefix   = "web-app-lt-"
#  image_id      = "ami-028eb925545f314d6"
#  instance_type = "t2.micro"
##  block_device_mappings {
##    device_name = "/dev/xvda"
##    ebs {
##      volume_size = 20
##    }
##  }
#  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
#  user_data ="${base64encode("init.sh")}"
#}
## note on the User Data above: In this code, ${data.aws_db_instance.data-rds.endpoint} fetches the RDS instance's
## endpoint (host) dynamically, and your EC2 instance will connect to the RDS instance without specifying a database name
## in the user_data script.
