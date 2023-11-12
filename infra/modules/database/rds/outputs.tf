output "rds_db_endpoint" {
  value = aws_db_instance.agile_ninjas_rds_db.endpoint
}

output "aws_db_instance_agile_ninjas_rds" {
  value = aws_db_instance.agile_ninjas_rds_db
}
