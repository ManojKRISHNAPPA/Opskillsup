terraform {
  required_version = "~> 1.16.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }
  }
}


provider "aws" {
    region = "ap-northeast-1"
}


resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-VPC"
  }
}


resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.demo_vpc.id
    cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.demo_vpc.id
    cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.demo_vpc.id
    tags = {
      Name = "Terraform_IGW"
    }
}

resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.demo_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public_subnet" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route.id
}

