# Pull region data and account id from provider
data "aws_region" "local" {
  provider = aws.local
}

data "aws_caller_identity" "local" {
  provider = aws.local
}

locals {
  local_account_id   = data.aws_caller_identity.local.account_id
  local_region_name  = data.aws_region.local.name
  local_region_label = lookup(var.region_az_labels, local.local_region_name)
  upper_env_prefix   = upper(var.env_prefix)
  default_tags = merge({
    Environment = var.env_prefix
  }, var.tags)
}

# one tgw that will route between all centralized routers.
resource "aws_ec2_transit_gateway" "local_this" {
  provider = aws.local

  amazon_side_asn                 = var.local_amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = merge(
    local.default_tags,
    {
      Name = format("%s-super-router-%s", local.upper_env_prefix, local.local_region_label)
  })
}

# Create the Peering attachment in the second account for the local provider
# iteration of over same regions
locals {
  local_centralized_routers = { for lcr in var.local_centralized_routers : lcr.id => lcr }
}

resource "aws_ec2_transit_gateway_peering_attachment" "local_peers" {
  provider = aws.local

  for_each = local.local_centralized_routers

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.value.id
  transit_gateway_id      = aws_ec2_transit_gateway.local_this.id
  tags = {
    Name = "tgw peer"
    Side = "Creator"
  }
}

# ...and accept it in the first account.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "local_locals" {
  provider = aws.local

  for_each = local.local_centralized_routers

  transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.local_peers, each.key).id
  tags = {
    Name = "tgw local"
    Side = "Acceptor"
  }
}

#TODO
# seperate iteration over cross region peering attachments (same acct)
# add routes to each vpc, use generate_routes_to_other_vpcs module??
# figure out tgw route overrides
