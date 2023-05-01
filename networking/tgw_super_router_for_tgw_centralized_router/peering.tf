locals {
  peering_name_format       = "%s <-> %s"
  peering_super_router_name = format(local.peering_name_format, local.local_super_router_name, local.peer_super_router_name)

  # renaming var to shorter name
  local_tgws                = [for this in var.super_router.local.centralized_routers : this]
  local_tgw_id_to_local_tgw = { for this in local.local_tgws : this.id => this }
  # renaming var to shorter name
  peer_tgws               = [for this in var.super_router.peer.centralized_routers : this]
  peer_tgw_id_to_peer_tgw = { for this in local.peer_tgws : this.id => this }
}

########################################################################################
# Begin Super Router Local Side to Peer Side
########################################################################################

# Create the Peering attachment in cross region to super router (same acct) for the peer provider
resource "aws_ec2_transit_gateway_peering_attachment" "this_local_to_this_peer" {
  provider = aws.local

  peer_account_id         = local.peer_account_id
  peer_region             = local.peer_region_name
  peer_transit_gateway_id = aws_ec2_transit_gateway.this_peer.id
  transit_gateway_id      = aws_ec2_transit_gateway.this_local.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.local_super_router_name, local.peer_super_router_name)
      Side = "Local Creator"
    }
  )
}

# accept it in cross region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_local_to_this_peer" {
  provider = aws.peer

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, local.peer_super_router_name, local.local_super_router_name)
      Side = "Peer Accepter"
    }
  )
}

########################################################################################
# Begin Centralized Router Local Side
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_local_to_locals" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.this_local.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, each.value.full_name, local.local_super_router_name)
      Side = "Local Creator"
    }
  )
}

# data source needed for intra-region peering.
# ref: https://github.com/hashicorp/terraform-provider-aws/issues/23828
data "aws_ec2_transit_gateway_peering_attachment" "this_local_to_locals" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  filter {
    name   = "transit-gateway-id"
    values = [each.key]
  }

  filter {
    name   = "state"
    values = ["available", "pendingAcceptance"]
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_local_to_locals]
}

# accept it in the same region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_local_to_locals" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  transit_gateway_attachment_id = lookup(data.aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.key).id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, each.value.full_name, local.local_super_router_name)
      Side = "Local Accepter"
    }
  )

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

########################################################################################
# Begin Centralized Router Peer Side
########################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this_peer_to_peers" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  peer_account_id         = each.value.account_id
  peer_region             = each.value.region
  peer_transit_gateway_id = each.key
  transit_gateway_id      = aws_ec2_transit_gateway.this_peer.id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, each.value.full_name, local.peer_super_router_name)
      Side = "Peer Creator"
    }
  )
}

# data source needed for intra-region peering.
# ref: https://github.com/hashicorp/terraform-provider-aws/issues/23828
data "aws_ec2_transit_gateway_peering_attachment" "this_peer_to_peers" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  filter {
    name   = "transit-gateway-id"
    values = [each.key]
  }

  filter {
    name   = "state"
    values = ["available", "pendingAcceptance"]
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers]
}

# accept it in the same region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_peer_to_peers" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  transit_gateway_attachment_id = lookup(data.aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers, each.key).id
  tags = merge(
    local.default_tags,
    {
      Name = format(local.peering_name_format, each.value.full_name, local.peer_super_router_name)
      Side = "Peer Accepter"
    }
  )

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}
