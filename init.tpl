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
docker run -d -p 80:5000 -e MYSQL_DATABASE_HOST="${db_endpoint}" -e MYSQL_DATABASE_USER="${rds_user}" -e MYSQL_DATABASE_PASSWORD="${rds_password}" -e MYSQL_DATABASE_DB=agile_ninjas weronikadocker/agile-ninjas-project
