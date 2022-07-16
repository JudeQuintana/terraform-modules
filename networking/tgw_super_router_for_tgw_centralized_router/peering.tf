# Create the Peering attachment in same region/acct for the local provider
# iteration of over centralized router in same region
locals {
  peering_name_format = "%s <-> %s"

  local_tgws          = var.local_centralized_routers
  local_tgw_id_to_tgw = { for this in local.local_tgws : this.id => this }
}

resource "aws_ec2_transit_gateway_peering_attachment" "this_local_peers" {
  provider = aws.local

  for_each = local.local_tgw_id_to_tgw

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.this_local.id
  tags = {
    Name = format(local.peering_name_format, each.value.name, local.super_router_name)
    Side = "Creator"
  }
}

# data source needed for intra-region peering.
# ref: https://github.com/hashicorp/terraform-provider-aws/issues/23828
data "aws_ec2_transit_gateway_peering_attachment" "this_local_accepter_peering_data" {
  provider = aws.local

  for_each = local.local_tgw_id_to_tgw

  filter {
    name   = "transit-gateway-id"
    values = [each.key]
  }

  filter {
    name   = "state"
    values = ["available", "pendingAcceptance"]
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_peers]
}

# accept it in the same region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_local_to_locals" {
  provider = aws.local

  for_each = local.local_tgw_id_to_tgw

  transit_gateway_attachment_id = lookup(data.aws_ec2_transit_gateway_peering_attachment.this_local_accepter_peering_data, each.key).id
  tags = {
    Name = format(local.peering_name_format, each.value.name, local.super_router_name)
    Side = "Accepter"
  }

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

########################################################################

# Create the Peering attachment in cross region to super router (same acct) for the peer provider
locals {
  peer_tgws          = var.peer_centralized_routers
  peer_tgw_id_to_tgw = { for this in local.peer_tgws : this.id => this }
}

resource "aws_ec2_transit_gateway_peering_attachment" "this_peer_to_peers" {
  provider = aws.local

  for_each = local.peer_tgw_id_to_tgw

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.this_local.id
  tags = {
    Name = format(local.peering_name_format, each.value.name, local.super_router_name)
    Side = "Creator"
  }
}

# accept it in cross region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_peer_to_locals" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_tgw

  transit_gateway_attachment_id = lookup(aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers, each.key).id
  tags = {
    Name = format(local.peering_name_format, each.value.name, local.super_router_name)
    Side = "Accepter"
  }
}
