##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.region
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################
locals {
  common_tags = {
    BillingCode = var.billing_code
  }
}

module "main" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.prefix
  cidr = var.cidr_block

  azs                     = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnets))
  public_subnets          = [for k, v in var.public_subnets : v]
  public_subnet_names     = [for k, v in var.public_subnets : "${var.prefix}-${k}"]
  enable_dns_hostnames    = true
  public_subnet_suffix    = ""
  public_route_table_tags = { Name = "${var.prefix}-public" }
  map_public_ip_on_launch = true

  enable_nat_gateway = false

  tags = local.common_tags
}

resource "aws_security_group" "ingress" {
  description            = "default VPC security group"
  egress                 = []
  ingress                = []
  name                   = "default"
  name_prefix            = null
  revoke_rules_on_delete = null
  tags = {
    Name = "sg-no-ingress"
  }
  tags_all = {
    Name = "sg-no-ingress"
  }
  vpc_id = "vpc-04b4230765613f68a"
}