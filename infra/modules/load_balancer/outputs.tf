output "app_load_balancer_dns_name" {
  value = aws_lb.app_load_balancer.dns_name
}

output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.lb_target_group.arn
}