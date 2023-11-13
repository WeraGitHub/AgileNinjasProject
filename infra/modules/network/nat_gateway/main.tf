variable "subnet_id" {}

# Create an Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  tags = {
    Name = "agile_ninjas_nat_gateway_eip"
  }
}

## NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id = var.subnet_id
  tags = {
    Name = "agile_ninjas_nat_gateway"
  }
}


