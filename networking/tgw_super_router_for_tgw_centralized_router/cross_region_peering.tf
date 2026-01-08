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
