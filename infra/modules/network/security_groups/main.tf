variable "vpc_id" {}


# Security groups
resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id
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
  vpc_id      = var.vpc_id
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
  vpc_id      = var.vpc_id
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
  vpc_id      = var.vpc_id
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
