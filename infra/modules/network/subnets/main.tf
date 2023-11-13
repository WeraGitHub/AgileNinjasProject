# Create private subnets using for_each
resource "aws_subnet" "private_subnet" {
  for_each = var.private_subnets
  vpc_id                  = var.vpc_id
  cidr_block              = each.value["cidr"]
  availability_zone       = "${var.region}${each.value["az"]}"
  map_public_ip_on_launch = false
  tags                    = {
    Name = "agile_ninjas_private_subnet_${each.value["az"]}"
  }
}

# Create public subnets using for_each
resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnets
  vpc_id                  = var.vpc_id
  cidr_block              = each.value["cidr"]
  availability_zone       = "${var.region}${each.value["az"]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "agile_ninjas_public_subnet_${each.value["az"]}"
  }
}

# Subnet group
resource "aws_db_subnet_group" "private_subnet_group" {
  name        = "private_subnet_group"
  description = "Private subnets group for our db"
  subnet_ids  = values(aws_subnet.private_subnet)[*].id
  tags = {
    Name = "agile_ninjas_private_subnet_group"
  }
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local" # Route traffic within the VPC locally
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = "agile_ninjas_public_route_table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_association" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local" # Route traffic within the VPC locally
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }

  tags = {
    Name = "agile_ninjas_private_route_table"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  for_each = aws_subnet.private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}
