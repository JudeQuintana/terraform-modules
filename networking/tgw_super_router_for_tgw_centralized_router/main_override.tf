# Pull region data and account id from provider
data "aws_region" "this_local_current" {
  provider = aws.local
}

data "aws_caller_identity" "this_local_current" {
  provider = aws.local
}

locals {
  local_account_id   = data.aws_caller_identity.this_local_current.account_id
  local_region_name  = data.aws_region.this_local_current.name
  local_region_label = lookup(var.region_az_labels, local.local_region_name)
  upper_env_prefix   = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

# generate single word random pet name for each super router tgw
resource "random_pet" "this" {
  for_each = toset([var.local_amazon_side_asn, var.peer_amazon_side_asn])

  length = 1
}

locals {
  base_super_router_name = format("%s-%s-%s", local.upper_env_prefix, "super-router", local.local_region_label)
}

resource "aws_ec2_transit_gateway" "this_local" {
  provider = aws.local

  amazon_side_asn                 = local.local_super_router_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = format("%s-%s", local.base_super_router_name, lookup(random_pet.this, var.local_amazon_side_asn)) }
  )
}

resource "aws_ec2_transit_gateway" "this_peer" {
  provider = aws.peer

  amazon_side_asn                 = var.peer_amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = format("%s-%s", local.base_super_router_name, lookup(random_pet.this, var.peer_amazon_side_asn)) }
  )
}
