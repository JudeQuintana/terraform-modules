# Pull caller identity data from provider
data "aws_caller_identity" "current" {}

# Pull region data from provider
data "aws_region" "current" {}

locals {
  account_id     = data.aws_caller_identity.current.account_id
  region_name    = data.aws_region.current.name
  region_label   = lookup(var.region_az_labels, local.region_name)
  route_any_cidr = "0.0.0.0/0"

  # Set Environment tag since we have have var.env_prefix
  # add or override with var.tags
  default_tags = merge({
    Environment = lower(var.env_prefix)
  }, var.tags)

  vpc_igw_name_tag = {
    Name = format("%s-%s-%s", upper(var.env_prefix), local.region_label, var.tier.name)
  }
}

######################################################
#
# Base VPC Setup:
# - VPC
# - IGW
#
######################################################

resource "aws_vpc" "this" {
  cidr_block           = var.tier.network
  instance_tenancy     = var.tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.default_tags,
    local.vpc_igw_name_tag
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    local.vpc_igw_name_tag
  )
}
