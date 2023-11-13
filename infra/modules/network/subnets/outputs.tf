output "public_subnet_a_id" {
  value = aws_subnet.public_subnet["a"].id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet["b"].id
}

output "public_subnet_c_id" {
  value = aws_subnet.public_subnet["c"].id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_subnet["a"].id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_subnet["b"].id
}

output "private_subnet_c_id" {
  value = aws_subnet.private_subnet["c"].id
}


output "aws_db_subnet_group_private_subnet_group_name" {
  value = aws_db_subnet_group.private_subnet_group.name
}
