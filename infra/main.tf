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

module "vpc" {
  source = "./modules/network/vpc"
}

module "subnets" {
  source              = "./modules/network/subnets"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.gateway_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
}

module "internet_gateway" {
  source = "./modules/network/internet_gateway"
  vpc_id = module.vpc.vpc_id
}

module "nat_gateway" {
  source    = "./modules/network/nat_gateway"
  subnet_id = module.subnets.public_subnet_a_id
}

module "security_groups" {
  source = "./modules/network/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source                 = "./modules/database/rds"
  rds_password           = var.rds_password
  db_subnet_group_name   = module.subnets.aws_db_subnet_group_private_subnet_group_name
  vpc_security_group_ids = [module.security_groups.aws_security_group_rds_id, module.security_groups.aws_security_group_pipe_id]
}

module "load_balancer" {
  source          = "./modules/load_balancer"
  vpc_id          = module.vpc.vpc_id
  subnets         = [module.subnets.public_subnet_a_id, module.subnets.public_subnet_b_id, module.subnets.public_subnet_c_id, ]
  security_groups = [module.security_groups.aws_security_group_lb_id]
}


module "compute" {
  source = "./modules/compute"

  #  for our ec2 template
  vpc_security_group_ec2_ids = [module.security_groups.aws_security_group_ec2_id]
  db_endpoint                = replace(module.rds.rds_db_endpoint, ":3306", "")
  rds_user                   = var.rds_user
  rds_password               = var.rds_password

  #  for auto scaling group
  vpc_zone_identifier = [module.subnets.private_subnet_a_id, module.subnets.private_subnet_b_id, module.subnets.private_subnet_c_id]
  target_group_arns   = [module.load_balancer.aws_lb_target_group_arn]

  #  for our pipeline ec2 instance
  public_subnet_b_id               = module.subnets.public_subnet_b_id
  vpc_security_group_pipe_ids      = [module.security_groups.aws_security_group_pipe_id]
  lb_dns_name                      = module.load_balancer.app_load_balancer_dns_name
  aws_db_instance_agile_ninjas_rds = module.rds.aws_db_instance_agile_ninjas_rds

}

#resource "null_resource" "hello" {
#  #  this can help run scripts in the local machines
#}