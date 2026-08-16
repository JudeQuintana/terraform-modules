locals {
  # renaming var to shorter name
  peer_tgws               = [for this in var.super_router.peer.centralized_routers : this]
  peer_tgw_id_to_peer_tgw = { for this in local.peer_tgws : this.id => this }
}

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
