variable "vpc_id" {}

resource "aws_internet_gateway" "public_igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "agile_ninjas_public_igw"
  }
}


