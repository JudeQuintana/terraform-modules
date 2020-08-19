# Pull region name from provider
data "aws_region" "current" {}

locals {
  route_out_cidr    = "0.0.0.0/0"
  region_name       = data.aws_region.current.name
  region_short_name = lookup(var.region_az_short_names, local.region_name)

  default_tags = {
    Environment = lower(var.env_prefix)
  }

  vpc_name_tag  = format("%s-%s-%s", upper(var.env_prefix), local.region_name, "default")
  public_label  = "public"
  private_label = "private"
  nat_gw_label  = "nat-gw"
}

######################################################
#
# Base VPC Setup:
# - VPC
# - IGW
#
######################################################

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.vpc_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.default_tags,
    {
      Name = local.vpc_name_tag
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.default_tags
}

######################################################
#
# Public Subnets:
# - Public Route Tables with Associtated Routes
# - Route out IGW
#
# Note: format("%s%s", local.region_name, each.key) is
#       building the AZ name on the fly by combining
#       the region with the letter designated for the AZ.
#
######################################################

resource "aws_subnet" "public" {
  for_each = var.azs

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = format("%s%s", local.region_name, each.key)
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value + 32)
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_short_names, format("%s%s", local.region_name, each.key)),
        local.public_label
      )
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.default_tags,
    {
      # This name doesnt change on the fly because I'm not setting the AZ
      # in the name and all public subnets route out the same IGW for
      # the whole region. This name can be pre-built like local.vpc_tag_name.
      Name = format(
        "%s-%s-%s",
        upper(var.env_prefix),
        local.region_short_name,
        local.public_label
      )
    }
  )
}

resource "aws_route" "public_route_out" {
  destination_cidr_block = local.route_out_cidr
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each = var.azs

  subnet_id      = lookup(aws_subnet.public, each.key).id
  route_table_id = aws_route_table.public.id

  lifecycle {
    # route_table_id is not needed here because the value
    # is not a part of the for_each iteration and therefore
    # wont trigger forcing a new resource
    ignore_changes = [subnet_id]
  }
}

######################################################
#
# Private Subnets:
# - Route Tables with Associtated Routes
# - Route out respective AZ NAT Gateway
#
######################################################

resource "aws_subnet" "private" {
  for_each = var.azs

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = format("%s%s", local.region_name, each.key)
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value)
  map_public_ip_on_launch = false
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_short_names, format("%s%s", local.region_name, each.key)),
        local.private_label
      )
    }
  )
}

resource "aws_route_table" "private" {
  for_each = var.azs

  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_short_names, format("%s%s", local.region_name, each.key)),
        local.private_label
      )
    }
  )
}

resource "aws_route" "private_route_out" {
  for_each = var.azs

  destination_cidr_block = local.route_out_cidr
  route_table_id         = lookup(aws_route_table.private, each.key).id
  nat_gateway_id         = lookup(aws_nat_gateway.ngws, each.key).id

  lifecycle {
    ignore_changes = [route_table_id, nat_gateway_id]
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.azs

  subnet_id      = lookup(aws_subnet.private, each.key).id
  route_table_id = lookup(aws_route_table.private, each.key).id

  lifecycle {
    ignore_changes = [subnet_id, route_table_id]
  }
}

######################################################
#
# EIPs:
# - Used for NAT Gateway's Public IP
#
######################################################

resource "aws_eip" "nat_ips" {
  for_each = var.azs

  vpc = true
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_short_names, format("%s%s", local.region_name, each.key)),
        local.nat_gw_label
      )
    }
  )
}

######################################################
#
# NAT Gatways:
# - For routing the respective private AZ traffic and
#   is built in a public subnet
# - depends_on is required because NAT GW needs an IGW
#   to route through but there is not an implicit
#   dependency via it's attributes so we must be
#   explicit.
#
######################################################

resource "aws_nat_gateway" "ngws" {
  for_each = var.azs

  allocation_id = lookup(aws_eip.nat_ips, each.key).id
  subnet_id     = lookup(aws_subnet.public, each.key).id
  tags = merge(
    local.default_tags,
    {
      Name = format(
        "%s-%s-%s",
        upper(var.env_prefix),
        lookup(var.region_az_short_names, format("%s%s", local.region_name, each.key)),
        local.nat_gw_label
      )
    },
  )

  depends_on = [aws_internet_gateway.igw]

  lifecycle {
    ignore_changes = [allocation_id, subnet_id]
  }
}

# usually want vpc.id, vpc.cidr_block, vpc.default_security_group_id
output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnet_ids" {
  value = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "private_subnet_ids" {
  value = { for az, subnet in aws_subnet.private : az => subnet.id }
}

# Each Public Subnet has the same Route Table
output "public_route_table_ids" {
  value = { for az, subnet in var.azs : az => aws_route_table.public.id }
}

output "private_route_table_ids" {
  value = { for az, route_table in aws_route_table.private : az => route_table.id }
}

