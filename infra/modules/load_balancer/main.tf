variable "vpc_id" {}
variable "subnets" {}
variable "security_groups" {}

# Application Load Balancer
resource "aws_lb" "app_load_balancer" {
  name = "app-load-balancer"
  #  internal = false
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = var.security_groups
}

# Load balancer target group
resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

# Load balancer listener
resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  tags = {
    Name = "agile_ninjas_load_balancer_listener"
  }
}