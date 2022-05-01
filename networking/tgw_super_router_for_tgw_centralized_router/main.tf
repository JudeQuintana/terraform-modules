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

# generate single word random pet name for tgw
resource "random_pet" "this" {
  length = 1
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
      Name = format("%s-%s-%s-%s", local.upper_env_prefix, "super-router", random_pet.this.id, local.local_region_label)
  })
}

# Create the Peering attachment in same region/acct for the local provider
# iteration of over centralized router in same region
locals {
  local_centralized_routers = { for lcr in var.local_centralized_routers : lcr.id => lcr }
}

resource "aws_ec2_transit_gateway_peering_attachment" "local_peers" {
  provider = aws.local

  for_each = local.local_centralized_routers

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.local_this.id
  tags = {
    Name = "same region tgw peer"
    Side = "Creator"
  }
}

# data source needed for intra-region peering.
# ref: https://github.com/hashicorp/terraform-provider-aws/issues/23828
data "aws_ec2_transit_gateway_peering_attachment" "local_acceptor_peering_data" {
  provider = aws.local

  for_each = local.local_centralized_routers

  filter {
    name   = "transit-gateway-id"
    values = [each.key]
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.local_peers]
}

# accept it in the same region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "local_locals" {
  provider = aws.local

  for_each = local.local_centralized_routers

  transit_gateway_attachment_id = lookup(data.aws_ec2_transit_gateway_peering_attachment.local_acceptor_peering_data, each.key).id
  tags = {
    Name = "same region tgw local"
    Side = "Acceptor"
  }

  #lifecycle {
  #ignore_changes = [transit_gateway_attachment_id]
  #}
  # might need ignore lifecycle on transit_gateway_id_attachment
  # because if a non-force-destroy attribute is changed
  # the data source wants to re-read settings and wants to force destroy
  # this resource. need to get more familiar with the data source behavior.
}

########################################################################

# Create the Peering attachment in cross region to super router (same acct) for the peer provider
locals {
  peer_centralized_routers = { for pcr in var.peer_centralized_routers : pcr.id => pcr }
}

resource "aws_ec2_transit_gateway_peering_attachment" "peer_peers" {
  provider = aws.local

  for_each = local.peer_centralized_routers

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.local_this.id
  tags = {
    Name = "cross region tgw peer"
    Side = "Creator"
  }
}

# accept it in cross region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peer_locals" {
  provider = aws.peer

  for_each = local.peer_centralized_routers

  transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.peer_peers, each.key).id
  tags = {
    Name = "cross region tgw peer"
    Side = "Acceptor"
  }
}

#TODO
# add routes to each vpc, use generate_routes_to_other_vpcs module??
# figure out tgw route overrides
# whatever else comes up
