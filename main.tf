variable "sql_script" {
  description = "SQL script for creating tables"
  type        = string
  default = <<EOF
CREATE TABLE `questions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `question` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `answer` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `category` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `questions` (`id`, `question`, `answer`, `category`)
VALUES
    (1, 'This is a very important Cyber Question', 'Answer here', 'Cyber'),
    (2, 'This is a very important Cyber Question 2', 'Answer here2', 'Cyber'),
    (3,'What is the purpose of the \'if __name__ == \'__main__\':\' statement in a Python script?','It ensures that the code within it only runs when the script is executed directly, not when imported as a module.','Python'),
	(4,'What does the term \'PEP 8\' refer to in Python programming?','It\'s the style guide for Python code, providing guidelines for formatting, naming conventions, and code structure.','Python'),
	(5,'How can you open a file in Python for both reading and writing?','By using the \'r+\' mode when opening the file.','Python'),
	(6,'What is the purpose of a virtual environment in Python development?','It creates an isolated environment for Python projects, allowing you to manage dependencies separately.','Python'),
	(7,'What is the difference between a list and a tuple in Python?','Lists are mutable, while tuples are immutable.','Python'),
	(8,'How do you catch and handle exceptions in Python?','Using a try-except block.','Python'),
	(9,'What is a lambda function in Python?','A small anonymous function defined using the lambda keyword.','Python'),
	(10,'What is the difference between \'==\' and \'is\' in Python?','\'==\' checks for equality, while \'is\' checks for object identity.','Python'),
	(11,'How do you sort a list of dictionaries based on a specific dictionary key?','By using the \'key\' parameter of the \'sorted()\' function with a lambda function that returns the desired key value.','Python'),
	(12,'What does the \'import this\' statement do in Python?','It displays the Zen of Python, a collection of guiding aphorisms for writing computer programs in Python.','Python'),
	(13,'What is AWS?','AWS (Amazon Web Services) is a cloud computing platform that provides a wide range of on-demand services for computing, storage, databases, networking, analytics, machine learning, and more.','AWS'),
	(14,'What is an EC2 instance?','An EC2 (Elastic Compute Cloud) instance is a virtual server in the cloud that you can use to run applications, services, and more.','AWS'),
	(15,'What is S3?','Amazon S3 (Simple Storage Service) is an object storage service that offers scalable and durable storage for data and files, accessible over the internet.','AWS'),
	(16,'What does IAM stand for in AWS?','IAM (Identity and Access Management) is a service that helps you manage access to AWS resources by controlling authentication and authorization.','AWS'),
	(17,'What is an AWS Lambda function?','AWS Lambda is a serverless compute service that lets you run code in response to events, such as changes to data in an S3 bucket or updates to a database.','AWS'),
	(18,'What is an Amazon RDS?','Amazon RDS (Relational Database Service) is a managed database service that makes it easier to set up, operate, and scale a relational database in the cloud.','AWS'),
	(19,'What is the AWS Elastic Beanstalk?','AWS Elastic Beanstalk is a Platform as a Service (PaaS) that allows you to deploy, manage, and scale applications without dealing with the underlying infrastructure.','AWS'),
	(20,'What is Amazon VPC?','Amazon VPC (Virtual Private Cloud) allows you to create isolated network environments within the AWS cloud and control the network configuration.','AWS'),
	(21,'What is Amazon ECS?','Amazon ECS (Elastic Container Service) is a fully managed container orchestration service that lets you easily run, scale, and manage Docker containers on AWS.','AWS'),
	(22,'What is Amazon CloudWatch?','Amazon CloudWatch is a monitoring and observability service that provides data and actionable insights to monitor your applications, resources, and services on AWS.','AWS'),
	(23,'What is DevOps?','DevOps is a set of practices that combines software development (Dev) and IT operations (Ops) to shorten the systems development life cycle while delivering features, fixes, and updates frequently and reliably.','DevOps'),
	(24,'What are the key benefits of DevOps?','Benefits of DevOps include faster software delivery, improved reliability, reduced risk, better collaboration between teams, and increased efficiency.','DevOps'),
	(25,'Name some popular DevOps tools.','Examples of DevOps tools include Docker, Jenkins, Ansible, Kubernetes, and Terraform.','DevOps'),
	(26,'What is Continuous Integration (CI)?','Continuous Integration is the practice of frequently integrating code changes into a shared repository. Each integration is verified by automated tests, allowing for early detection of integration issues.','DevOps'),
	(27,'What is Continuous Deployment (CD)?','Continuous Deployment is the practice of automatically deploying code changes to production after passing automated tests and meeting specified criteria.','DevOps'),
	(28,'What is Infrastructure as Code (IaC)?','Infrastructure as Code is the practice of managing and provisioning infrastructure using code and automation tools.','DevOps'),
	(29,'What is a microservices architecture?','Microservices architecture is an approach to designing software applications as a collection of loosely coupled services that can be developed, deployed, and scaled independently.','DevOps'),
	(30,'What is monitoring in DevOps?','Monitoring in DevOps involves observing the health, performance, and availability of software systems, often through automated tools.','DevOps'),
	(31,'Explain the concept of \'Shift Left\' in DevOps.','\'Shift Left\' refers to the practice of moving tasks such as testing, security, and quality checks earlier in the development process to identify and address issues sooner.','DevOps'),
	(32,'What is the goal of Continuous Monitoring in DevOps?','The goal of Continuous Monitoring is to provide real-time visibility into the performance and health of applications and infrastructure, enabling rapid response to issues.','DevOps'),
	(33,'test','James test','Cyber'),
	(34,'test 3 now ha!','test test','Cyber');
EOF
}


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
#
## Create a route to send local traffic within VPC for the public route table
#resource "aws_route" "public_route_local" {
#  route_table_id         = aws_route_table.public_route_table.id
#  destination_cidr_block = "10.0.0.0/16"  # Local VPC traffic
##  local = true
#
#}
#
## Create a route to send internet-bound traffic to the Internet Gateway for the public route table
#resource "aws_route" "public_route_igw" {
#  route_table_id         = aws_route_table.public_route_table.id
#  destination_cidr_block = "0.0.0.0/0"  # All traffic (Internet)
#  gateway_id             = aws_internet_gateway.public_igw.id
#}

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

#  route {
#    cidr_block = "10.0.0.0/16"
##    nat_gateway_id = aws_nat_gateway.nat_gateway.id
#  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}

## Create a route to send local traffic within VPC for the private route table
#resource "aws_route" "private_route_local" {
#  route_table_id         = aws_route_table.private_route_table.id
#  destination_cidr_block = "10.0.0.0/16"  # Local VPC traffic
#  nat_gateway_id = aws_nat_gateway.nat_gateway.id
#}
#
## Create a route to send internet-bound traffic to the NAT Gateway for the private route table
#resource "aws_route" "private_route_nat_gateway" {
#  route_table_id         = aws_route_table.private_route_table.id
#  destination_cidr_block = "0.0.0.0/0"  # All traffic (NAT Gateway)
#  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
#}

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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
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


# RDS
#data "template_file" "create_questions_table_sql" {
#  template = file("${path.module}/create_questions_table.sql")
#}
#
#resource "aws_db_parameter_group" "rds_parameter_group" {
#  name        = "rds-parameter-group"
#  family      = "mysql8.0"
#  description = "Custom parameter group for MySQL 8.0"
#}
#
#resource "aws_db_parameter_group_parameter" "log_bin_trust_function_creators" {
#  name   = "log_bin_trust_function_creators"
#  value  = "1"
#  apply_immediately = true
#  parameter_group_name = aws_db_parameter_group.rds_parameter_group.name
#}



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
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

#   provisioner "local-exec" {
#    command = <<-EOT
#      mysql -h ${self.endpoint} -u ${var.rds_user} -p${var.rds_password} < <(echo "${data.template_file.create_questions_table_sql.rendered}")
#    EOT
#  }
#  provisioner "local-exec" {
#    command = <<-EOT
#      mysql -h ${self.endpoint} -u ${var.rds_user} -p${var.rds_password} <<< "${var.sql_script}"
#    EOT
#  }

  provisioner "local-exec" {
    command = <<-EOT
      mysql -h ${data.aws_db_instance.data-rds.endpoint} -P 3306 -u ${var.rds_user} -p${var.rds_password} <<EOF
      CREATE TABLE questions (
        id int unsigned NOT NULL AUTO_INCREMENT,
        question varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        answer varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        category varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
        PRIMARY KEY (id)
      ) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

      INSERT INTO questions (id, question, answer, category)
      VALUES
          (1, 'This is a very important Cyber Question', 'Answer here', 'Cyber'),
          (2, 'This is a very important Cyber Question 2', 'Answer here2', 'Cyber'),
          (3,'What is the purpose of the \'if __name__ == \'__main__\':\' statement in a Python script?','It ensures that the code within it only runs when the script is executed directly, not when imported as a module.','Python'),
          (4,'What does the term \'PEP 8\' refer to in Python programming?','It\'s the style guide for Python code, providing guidelines for formatting, naming conventions, and code structure.','Python'),
          (5,'How can you open a file in Python for both reading and writing?','By using the \'r+\' mode when opening the file.','Python'),
          (6,'What is the purpose of a virtual environment in Python development?','It creates an isolated environment for Python projects, allowing you to manage dependencies separately.','Python'),
          (7,'What is the difference between a list and a tuple in Python?','Lists are mutable, while tuples are immutable.','Python'),
          (8,'How do you catch and handle exceptions in Python?','Using a try-except block.','Python'),
          (9,'What is a lambda function in Python?','A small anonymous function defined using the lambda keyword.','Python'),
          (10,'What is the difference between \'==\' and \'is\' in Python?','\'==\' checks for equality, while \'is\' checks for object identity.','Python'),
          (11,'How do you sort a list of dictionaries based on a specific dictionary key?','By using the \'key\' parameter of the \'sorted()\' function with a lambda function that returns the desired key value.','Python'),
          (12,'What does the \'import this\' statement do in Python?','It displays the Zen of Python, a collection of guiding aphorisms for writing computer programs in Python.','Python'),
          (13,'What is AWS?','AWS (Amazon Web Services) is a cloud computing platform that provides a wide range of on-demand services for computing, storage, databases, networking, analytics, machine learning, and more.','AWS'),
          (14,'What is an EC2 instance?','An EC2 (Elastic Compute Cloud) instance is a virtual server in the cloud that you can use to run applications, services, and more.','AWS'),
          (15,'What is S3?','Amazon S3 (Simple Storage Service) is an object storage service that offers scalable and durable storage for data and files, accessible over the internet.','AWS'),
          (16,'What does IAM stand for in AWS?','IAM (Identity and Access Management) is a service that helps you manage access to AWS resources by controlling authentication and authorization.','AWS'),
          (17,'What is an AWS Lambda function?','AWS Lambda is a serverless compute service that lets you run code in response to events, such as changes to data in an S3 bucket or updates to a database.','AWS'),
          (18,'What is an Amazon RDS?','Amazon RDS (Relational Database Service) is a managed database service that makes it easier to set up, operate, and scale a relational database in the cloud.','AWS'),
          (19,'What is the AWS Elastic Beanstalk?','AWS Elastic Beanstalk is a Platform as a Service (PaaS) that allows you to deploy, manage, and scale applications without dealing with the underlying infrastructure.','AWS'),
          (20,'What is Amazon VPC?','Amazon VPC (Virtual Private Cloud) allows you to create isolated network environments within the AWS cloud and control the network configuration.','AWS'),
          (21,'What is Amazon ECS?','Amazon ECS (Elastic Container Service) is a fully managed container orchestration service that lets you easily run, scale, and manage Docker containers on AWS.','AWS'),
          (22,'What is Amazon CloudWatch?','Amazon CloudWatch is a monitoring and observability service that provides data and actionable insights to monitor your applications, resources, and services on AWS.','AWS'),
          (23,'What is DevOps?','DevOps is a set of practices that combines software development (Dev) and IT operations (Ops) to shorten the systems development life cycle while delivering features, fixes, and updates frequently and reliably.','DevOps'),
          (24,'What are the key benefits of DevOps?','Benefits of DevOps include faster software delivery, improved reliability, reduced risk, better collaboration between teams, and increased efficiency.','DevOps'),
          (25,'Name some popular DevOps tools.','Examples of DevOps tools include Docker, Jenkins, Ansible, Kubernetes, and Terraform.','DevOps'),
          (26,'What is Continuous Integration (CI)?','Continuous Integration is the practice of frequently integrating code changes into a shared repository. Each integration is verified by automated tests, allowing for early detection of integration issues.','DevOps'),
          (27,'What is Continuous Deployment (CD)?','Continuous Deployment is the practice of automatically deploying code changes to production after passing automated tests and meeting specified criteria.','DevOps'),
          (28,'What is Infrastructure as Code (IaC)?','Infrastructure as Code is the practice of managing and provisioning infrastructure using code and automation tools.','DevOps'),
          (29,'What is a microservices architecture?','Microservices architecture is an approach to designing software applications as a collection of loosely coupled services that can be developed, deployed, and scaled independently.','DevOps'),
          (30,'What is monitoring in DevOps?','Monitoring in DevOps involves observing the health, performance, and availability of software systems, often through automated tools.','DevOps'),
          (31,'Explain the concept of \'Shift Left\' in DevOps.','\'Shift Left\' refers to the practice of moving tasks such as testing, security, and quality checks earlier in the development process to identify and address issues sooner.','DevOps'),
          (32,'What is the goal of Continuous Monitoring in DevOps?','The goal of Continuous Monitoring is to provide real-time visibility into the performance and health of applications and infrastructure, enabling rapid response to issues.','DevOps'),
          (33,'test','James test','Cyber');
      EOF
    EOT
  }

}

#resource "aws_network_interface_sg_attachment" "rds_sg_attachment" {
#  security_group_id    = aws_security_group.rds_sg.id
##  network_interface_id = aws_instance.agile_app.primary_network_interface_id
#  network_interface_id = aws_db_instance.agile-ninjas-rds-db.
#}

# Data block to fetch RDS endpoint
data "aws_db_instance" "data-rds" {
  db_instance_identifier = aws_db_instance.agile-ninjas-rds-db.id
}

# EC2 template
resource "aws_launch_template" "web-app-template" {
  name_prefix   = "web-app-lt-"
  image_id      = "ami-028eb925545f314d6"
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
#  user_data = <<EOF
##!/bin/bash
## This script initializes the EC2 instance for the web application.
## Redirect script output to log file
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
## Update the instance
#yum update -y
## Install Docker
#yum install -y docker
#service docker start
## Pull and run the Docker container
#docker pull weronikadocker/agile-ninjas-project
#docker run -d -p 80:5000 -e MYSQL_DATABASE_HOST="${data.aws_db_instance.data-rds.endpoint}" -e MYSQL_DATABASE_USER="${var.rds_user}" -e MYSQL_DATABASE_PASSWORD="${var.rds_password}" -e MYSQL_DATABASE_DB=agile_ninjas weronikadocker/agile-ninjas-project
#EOF

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



