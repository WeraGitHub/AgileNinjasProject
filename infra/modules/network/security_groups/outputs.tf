output "aws_security_group_rds_id" {
  value = aws_security_group.rds_sg.id
}

output "aws_security_group_pipe_id" {
  value = aws_security_group.pipe_sg.id
}

output "aws_security_group_ec2_id" {
  value = aws_security_group.ec2_sg.id
}

output "aws_security_group_lb_id" {
  value = aws_security_group.lb_sg.id
}