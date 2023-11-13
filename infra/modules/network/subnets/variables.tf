variable "vpc_id" {}
variable "internet_gateway_id" {}
variable "nat_gateway_id" {}

# Subnets

variable "region" {
  default = "eu-west-2"
}

variable "subnet_keys" {
  type = set(string)
  default = ["a", "b", "c"]
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az = string
  }))
  default = {
    a = {
      cidr = "10.0.0.0/24"
      az = "a"
    }
    b = {
      cidr = "10.0.1.0/24"
      az = "b"
    }
    c = {
      cidr = "10.0.2.0/24"
      az = "c"
    }
  }
}


variable "public_subnets" {
  type = map(object({
    cidr = string
    az = string
  }))
  default = {
    a = {
      cidr = "10.0.3.0/24"
      az = "a"
    }
    b = {
      cidr = "10.0.4.0/24"
      az = "b"
    }
    c = {
      cidr = "10.0.5.0/24"
      az = "c"
    }
  }
}