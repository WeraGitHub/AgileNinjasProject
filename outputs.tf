#output "address" {
#  value = aws_instance.web.*.public_dns
#}
#output "instance_ips" {
#  value = aws_instance.web.*.public_ip
#}


output "site_address" {
  value = "${aws_lb.app-load-balancer.dns_name}"
}
#  value = "${aws_elb.app-load-balancer.dns_name}"
