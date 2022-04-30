# Pull caller identity data from provider
data "aws_caller_identity" "current" {}

# Pull region data from provider
data "aws_region" "current" {}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  region_name      = data.aws_region.current.name
  region_label     = lookup(var.region_az_labels, local.region_name)
  upper_env_prefix = upper(var.env_prefix)

  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

# generate single word random pet name for tgw
resource "random_pet" "this" {
  length = 1
}

# one tgw that will route between all tiered vpcs.
resource "aws_ec2_transit_gateway" "this" {
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    {
      Name = format("%s-%s-%s-%s", local.upper_env_prefix, "centralized-router", random_pet.this.id, local.region_label)
  })
}

locals {
  # collect the first public subnet for each az per tiered vpc to be used for each vpc attachment.
  # i'm using public subnets because they will always exist for a tiered vpc.
  # this means routing will go through a public subnet to get to a private subnet in the same AZ
  # private subnets could be used too
  # i'm not sure about security implications of this pattern but i dont think it matters.
  #
  # { vpc-1-id  = [ "first-public-subnet-id-of-az-1-for-vpc-1", "first-public-subnet-id-of-az-2-for-vpc-1", ... ], ...}
  vpc_id_to_single_public_subnet_ids_per_az = {
    for vpc_name, this in var.vpcs :
    this.id => [for az, public_subnet_ids in this.az_to_public_subnet_ids : element(public_subnet_ids, 0)]
  }

  # lookup table for each aws_ec2_transit_gateway_vpc_attachment to get the name based on id
  vpc_id_to_names = { for vpc_name, this in var.vpcs : this.id => vpc_name }
}

# attach vpcs to tgw
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = local.vpc_id_to_single_public_subnet_ids_per_az

  subnet_ids                                      = each.value
  transit_gateway_id                              = aws_ec2_transit_gateway.this.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id                                          = each.key
  tags = merge(
    local.default_tags,
    {
      Name = lookup(local.vpc_id_to_names, each.key)
  })
}

# one route table for all vpc networks
resource "aws_ec2_transit_gateway_route_table" "this" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = merge(
    local.default_tags,
    {
      Name = format("%s-%s-%s", local.upper_env_prefix, random_pet.this.id, local.region_label)
  })
}

# associate attachments to route table
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = local.vpc_id_to_single_public_subnet_ids_per_az

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

# route table propagation
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.vpc_id_to_single_public_subnet_ids_per_az

  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_vpc_attachment.this, each.key).id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

# Create routes to other VPC networks in private and public route tables for each VPC
locals {
  # { vpc-1-network => [ "vpc-1-private-rtb-id-1", "vpc-1-public-rtb-id-1", ... ], ...}
  vpc_network_to_private_and_public_route_table_ids = {
    for vpc_name, this in var.vpcs :
    this.network => concat(values(this.az_to_private_route_table_id), values(this.az_to_public_route_table_id))
  }

  # [ { rtb_id = "vpc-1-rtb-id-123", other_networks = [ "other-vpc-2-network", "other-vpc3-network", ... ] }, ...]
  associate_private_and_public_route_table_ids_with_other_networks = flatten(
    [for network, rtb_ids in local.vpc_network_to_private_and_public_route_table_ids :
      [for rtb_id in rtb_ids : {
        rtb_id         = rtb_id
        other_networks = [for n in keys(local.vpc_network_to_private_and_public_route_table_ids) : n if n != network]
  }]])

  # { rtb-id|route => route, ... }
  private_and_public_routes_to_other_networks = merge(
    [for r in local.associate_private_and_public_route_table_ids_with_other_networks :
      { for rtb_id_and_route in setproduct([r.rtb_id], r.other_networks) :
        format("%s|%s", rtb_id_and_route[0], rtb_id_and_route[1]) => rtb_id_and_route[1] # each key must be unique, dont group by key
  }]...)
}

resource "aws_route" "this" {
  for_each = local.private_and_public_routes_to_other_networks

  destination_cidr_block = each.value
  route_table_id         = split("|", each.key)[0]
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}
