resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dev_public_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-west-2a"

    tags = {
        Name = "dev-public-subnet"
    }
}