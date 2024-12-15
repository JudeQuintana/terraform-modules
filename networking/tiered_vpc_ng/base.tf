# Note from AWS:
# Some AWS services use the 172.17.0.0/16 CIDR range. To avoid future conflicts, don’t use this range when creating your VPC.
# ^will not explicitly block this cidr via variable validation but important to know.

# Pull caller identity data from provider
data "aws_caller_identity" "this" {}

# Pull region data from provider
data "aws_region" "this" {}

locals {
  account_id          = data.aws_caller_identity.this.account_id
  region_name         = data.aws_region.this.name
  region_label        = lookup(var.region_az_labels, local.region_name)
  route_any_cidr      = "0.0.0.0/0"
  route_any_ipv6_cidr = "::/0"
  upper_env_prefix    = upper(var.env_prefix)

  # Set Environment tag since we have have var.env_prefix
  # add or override with var.tags
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)

  # the tiered-vpc name is redundant when viewing in vpc aws console
  # but is most useful when viewing a TGW's VPC attachment.
  vpc_full_name = format("%s-tiered-vpc-%s-%s", local.upper_env_prefix, var.tiered_vpc.name, local.region_label)
}

resource "aws_vpc" "this" {
  cidr_block           = var.tiered_vpc.ipv4.network_cidr
  ipv4_ipam_pool_id    = var.tiered_vpc.ipv4.ipam_pool.id
  ipv6_cidr_block      = var.tiered_vpc.ipv6.network_cidr
  ipv6_ipam_pool_id    = var.tiered_vpc.ipv6.ipam_pool.id
  enable_dns_support   = var.tiered_vpc.dns_support
  enable_dns_hostnames = var.tiered_vpc.dns_hostnames
  tags = merge(
    local.default_tags,
    { Name = local.vpc_full_name }
  )

  # only using cidrs
  lifecycle {
    ignore_changes = [ipv4_netmask_length, ipv6_netmask_length]
  }
}

locals {
  secondary_cidrs = toset(var.tiered_vpc.ipv4.secondary_cidrs)
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each = local.secondary_cidrs

  cidr_block        = each.key
  vpc_id            = aws_vpc.this.id
  ipv4_ipam_pool_id = var.tiered_vpc.ipv4.ipam_pool.id

  # only using cidrs
  lifecycle {
    ignore_changes = [ipv4_netmask_length]
  }
}

locals {
  ipv6_secondary_cidrs = toset(var.tiered_vpc.ipv6.secondary_cidrs)
}

resource "aws_vpc_ipv6_cidr_block_association" "this" {
  for_each = local.ipv6_secondary_cidrs

  ipv6_cidr_block   = each.key
  vpc_id            = aws_vpc.this.id
  ipv6_ipam_pool_id = var.tiered_vpc.ipv6.ipam_pool.id

  # only using cidrs
  lifecycle {
    ignore_changes = [ipv6_netmask_length]
  }
}

locals {
  igw = { for this in [local.public_any_subnet_exists] : this => this if local.public_any_subnet_exists }
}

resource "aws_internet_gateway" "this" {
  for_each = local.igw

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    { Name = local.vpc_full_name }
  )
}

locals {
  eigw = { for this in [local.private_ipv6_any_eigw_enabled] : this => this if local.private_ipv6_any_eigw_enabled }
}

resource "aws_egress_only_internet_gateway" "this" {
  for_each = local.eigw

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.default_tags,
    { Name = local.vpc_full_name }
  )
}
