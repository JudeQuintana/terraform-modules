# Pull caller identity data from provider
data "aws_caller_identity" "this" {}

# Pull region data from provider
data "aws_region" "this" {}

locals {
  account_id       = data.aws_caller_identity.this.account_id
  region_name      = data.aws_region.this.name
  region_label     = lookup(var.region_az_labels, local.region_name)
  route_any_cidr   = "0.0.0.0/0"
  upper_env_prefix = upper(var.env_prefix)

  # Set Environment tag since we have have var.env_prefix
  # add or override with var.tags
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)

  # the tiered-vpc name is redundant when viewing in vpc aws console
  # but is most useful when viewing a TGW's VPC attachment.
  vpc_name = format("%s-tiered-vpc-%s-%s", local.upper_env_prefix, var.tiered_vpc.name, local.region_label)
}

######################################################
#
# Base VPC Setup:
# - VPC
# - IGW
#
######################################################

resource "aws_vpc" "this" {
  cidr_block           = var.tiered_vpc.network_cidr
  instance_tenancy     = var.tiered_vpc.tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.default_tags,
    { Name = local.vpc_name }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    { Name = local.vpc_name }
  )
}
