#!/bin/bash
# This script initializes the EC2 instance for the JEnkins and Docker and MySql for pipeline and such.

# Update the instance
yum update -y

# Install Docker
yum install -y docker
service docker start

# Install Jenkins
yum -y update
yum remove java* -y
yum install -y java-17-amazon-corretto
yum install git -y
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y
service jenkins start
chkconfig jenkins on

# Install MySql
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld


mysql -h "${db_endpoint}" -P 3306 -u ${rds_user} -p${rds_password} <<EOF
    USE agile_ninjas;
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
