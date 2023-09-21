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



# EC2 template
resource "aws_instance" "web-app-instance" {
#  vpc_id = "vpc-099f2db13065a484d"
  ami = "ami-028eb925545f314d6"
  instance_type = "t2.micro"
#  block_device_mappings {
#    device_name = "/dev/xvda"
#    ebs {
#      volume_size = 20
#    }
#  }
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
#  user_data =base64encode(init.sh)
#  user_data = file("./init.sh")
#  user_data = base64encode(file("./init.sh"))
#  try this one next:
#  user_data = "${file("./init.sh")}"
#  another idea is to go back to having the script here instead of referencing the file.
  user_data = <<EOF
#!/bin/bash
# This script initializes the EC2 instance for the web application.
# Redirect script output to log file
# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Update the instance
yum update -y
# Install Docker
yum install -y docker
service docker start
# Pull and run the Docker container
docker pull weronikadocker/agile-ninjas-project

docker run -d -p 80:5000 weronikadocker/sky-project

EOF

}


resource "aws_security_group" "ec2_sg" {
  vpc_id = "vpc-099f2db13065a484d"
  name = "ec2_sg"
  description = "EC2 Security Group - allow HTTP traffic from ELB security group"
  # Inbound: Allows HTTP (80) traffic only from the Load Balancer's security group.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
#    security_groups = [aws_security_group.lb_sg.id]
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