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

# generate single word random pet name for each trifecta tgw
resource "random_pet" "this" {
  for_each = toset(var.amazon_side_asns)

  length = 1
}

locals {
  base_super_router_name = format("%s-%s-%s", local.upper_env_prefix, "super-router", local.local_region_label)
  local_trifecta_tgws    = toset(slice(var.amazon_side_asns, 0, 2)) # first two elements
  peer_trifecta_tgws     = toset(slice(var.amazon_side_asns, 2, 3)) # last element
}

resource "aws_ec2_transit_gateway" "this_locals" {
  provider = aws.local

  for_each = local.local_trifecta_tgws

  amazon_side_asn                 = each.key
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = format("%s-%s", local.base_super_router_name, lookup(random_pet.this, each.key)) }
  )
}

resource "aws_ec2_transit_gateway" "this_peers" {
  provider = aws.peer

  for_each = local.peer_trifecta_tgws

  amazon_side_asn                 = each.key
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    { Name = format("%s-%s", local.base_super_router_name, lookup(random_pet.this, each.key)) }
  )
}
