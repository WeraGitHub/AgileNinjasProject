variable "rds_password" {}
variable "db_subnet_group_name" {}
variable "vpc_security_group_ids" {}


resource "aws_db_instance" "agile_ninjas_rds_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t3.micro"
  db_name                = "agile_ninjas"
  username               = "root"
  password               = var.rds_password
  db_subnet_group_name   = var.db_subnet_group_name
  multi_az               = true # Enable multi-AZ deployment
  skip_final_snapshot    = true
  vpc_security_group_ids = var.vpc_security_group_ids
  tags = {
    Name = "agile_ninjas_rds_db"
  }
}
