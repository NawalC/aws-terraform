terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

}

provider "aws" {
  profile = "terraform"
  region  = "eu-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    project = "network-layer"
  }
}

resource "aws_subnet" "public_sub" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "network-layer"
  }
}

resource "aws_subnet" "private_sub" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.4.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "network-layer"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "network-layer"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "network-layer"
  }
}

resource "aws_route_table_association" "public_rtb_assoc" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.public_rtb.id
}

# NAT Elastic IP address to talk to public subnet
resource "aws_eip" "nat_eip" {
    vpc      = true

  tags = {
    Name = "network-layer"
  }
}

#NAT enables an instance in a private subnet to connect to the internet

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sub.id

  tags = {
    Name = "network-layer"
  }
}
#Private subnet route table

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "network-layer"
  }

}

resource "aws_route_table_association" "private_rtb_assoc" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.private_rtb.id

}