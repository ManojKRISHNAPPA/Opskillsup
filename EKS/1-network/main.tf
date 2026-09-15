data "aws_availability_zones" "available"{}

locals {
  azs = var.azs

  tags = {
    Project = var.project
  } 
}