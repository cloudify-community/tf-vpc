terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.22.0"
    }
  }
}

variable "aws_region" {
  type = string
}

variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "vpc_tags" {
  type = map(string)
}

variable "availability_zone_1" {
  type = string
}

variable "availability_zone_2" {
  type = string
}

variable "subnet_1_cidr" {
  type = string
}

variable "subnet_2_cidr" {
  type = string
}

variable "subnet_1_tags" {
  type = map(string)
}

variable "subnet_2_tags" {
  type = map(string)
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = var.vpc_tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = join("-", [
      var.name,
      "internet-gateway"])
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_1_cidr
  availability_zone = var.availability_zone_1

  tags = var.subnet_1_tags
}

resource "aws_subnet" "subnet_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_2_cidr
  availability_zone = var.availability_zone_2
  tags = var.subnet_2_tags
}

resource "aws_security_group" "agents_security_group" {
  vpc_id = aws_vpc.vpc.id
  name = join("-", [var.name, "cfy-agents"])
}

resource "aws_security_group_rule" "agents_security_group_rule_ssh" {
  type = "ingress"
  security_group_id = aws_security_group.agents_security_group.id
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "agents_security_group_rule_outgoing" {
  type = "egress"
  security_group_id = aws_security_group.agents_security_group.id
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id
  ]
}

output "availability_zones" {
  value =[
    aws_subnet.subnet_1.availability_zone,
    aws_subnet.subnet_2.availability_zone
  ]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.internet_gateway.id
}

output "agents_security_group_id" {
  value = aws_security_group.agents_security_group.id
}
