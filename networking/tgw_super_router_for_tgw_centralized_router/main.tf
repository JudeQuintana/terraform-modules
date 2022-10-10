# Pull region data and account id from provider
data "aws_region" "this_local_current" {
  provider = aws.local
}

data "aws_caller_identity" "this_local_current" {
  provider = aws.local
}

data "aws_region" "this_peer_current" {
  provider = aws.peer
}

data "aws_caller_identity" "this_peer_current" {
  provider = aws.peer
}

locals {
  local_account_id   = data.aws_caller_identity.this_local_current.account_id
  local_region_name  = data.aws_region.this_local_current.name
  local_region_label = lookup(var.region_az_labels, local.local_region_name)

  peer_account_id   = data.aws_caller_identity.this_peer_current.account_id
  peer_region_name  = data.aws_region.this_peer_current.name
  peer_region_label = lookup(var.region_az_labels, local.peer_region_name)

  upper_env_prefix = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)


  random_super_router_names = toset([var.local_amazon_side_asn, var.peer_amazon_side_asn])
}

# generate single word random pet name for each super router tgw
resource "random_pet" "this" {
  for_each = local.random_super_router_names

  length = 1
}

locals {
  base_super_router_name  = format("%s-%s", local.upper_env_prefix, "super-router")
  local_super_router_name = format("%s-%s-%s", local.base_super_router_name, local.local_region_label, lookup(random_pet.this, var.local_amazon_side_asn).id)
  peer_super_router_name  = format("%s-%s-%s", local.base_super_router_name, local.peer_region_label, lookup(random_pet.this, var.peer_amazon_side_asn).id)
}

resource "aws_ec2_transit_gateway" "this_local" {
  provider = aws.local

  amazon_side_asn                 = var.local_amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = local.local_super_router_name }
  )
}

resource "aws_ec2_transit_gateway" "this_peer" {
  provider = aws.peer

  amazon_side_asn                 = var.peer_amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = local.peer_super_router_name }
  )
}
