# modules/subnets/main.tf

variable "vpc_id" {}
variable "internet_gateway_id" {}
variable "nat_gateway_id" {}

# Subnets

# for each loops block for the subnets
# or count, but use for each, because count can be problematic

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "agile_ninjas_private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false
  tags = {
    Name = "agile_ninjas_private_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = false
  tags = {
    Name = "agile_ninjas_private_subnet_c"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "agile_ninjas_public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "agile_ninjas_public_subnet_b"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "agile_ninjas_public_subnet_c"
  }
}

# Subnet group
resource "aws_db_subnet_group" "private_subnet_group" {
  name        = "private_subnet_group"
  description = "Private subnets group for our db"
  subnet_ids  = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id, aws_subnet.private_subnet_c.id]
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
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
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
resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_route_table.id
}