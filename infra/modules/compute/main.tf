variable "vpc_security_group_ec2_ids" {}
variable "db_endpoint" {}
variable "rds_user" {}
variable "rds_password" {}

variable "vpc_zone_identifier" {}
variable "target_group_arns" {}

variable "public_subnet_b_id" {}
variable "vpc_security_group_pipe_ids" {}
variable "lb_dns_name" {}
variable "aws_db_instance_agile_ninjas_rds" {}


# EC2 template
resource "aws_launch_template" "web_app_template" {
  name_prefix            = "web-app-lt-"
  image_id               = "ami-028eb925545f314d6"
  instance_type          = "t2.micro"
  vpc_security_group_ids = var.vpc_security_group_ec2_ids
  user_data = base64encode(templatefile("${path.module}/init.tpl",
    {
      # remove port number in case it's attached to the endpoint
      db_endpoint  = var.db_endpoint,
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
  vpc_zone_identifier       = var.vpc_zone_identifier
  health_check_type         = "ELB"
  health_check_grace_period = 300 # 5 minutes grace period
  # Attach the ASG to the ALB target group
  target_group_arns = var.target_group_arns
}


# Pipeline EC2
resource "aws_instance" "pipeline_ec2" {
  subnet_id              = var.public_subnet_b_id
  ami                    = "ami-028eb925545f314d6"
  instance_type          = "t2.medium"
  vpc_security_group_ids = var.vpc_security_group_pipe_ids
  # in future the set up and installation of tools should be cooked using Ansible, for now this is a 'smart' work around
  user_data = base64encode(templatefile("${path.module}/pipeinit.tpl",
    {
      db_endpoint  = var.db_endpoint,
      rds_user     = var.rds_user,
      rds_password = var.rds_password,
      lb_dns_name  = var.lb_dns_name,
    }
  ))
  tags = {
    Name = "agile_ninjas_pipeline-instance"
  }
  depends_on = [var.aws_db_instance_agile_ninjas_rds]
}
