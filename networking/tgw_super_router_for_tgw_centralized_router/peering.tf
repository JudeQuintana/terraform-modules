locals {
  peering_name_format = "%s <-> %s"
}

# Create the Peering attachment in cross region to super router (same acct) for the peer provider
resource "aws_ec2_transit_gateway_peering_attachment" "this_local_to_this_peer" {
  provider = aws.local

  peer_account_id         = data.aws_caller_identity.this_peer_current.account_id
  peer_region             = data.aws_region.this_peer_current.name
  peer_transit_gateway_id = aws_ec2_transit_gateway.this_peer.id
  transit_gateway_id      = aws_ec2_transit_gateway.this_local.id
  tags = {
    Name = format(local.peering_name_format, local.local_super_router_name, local.peer_super_router_name)
    Side = "Local Creator"
  }
}

# accept it in cross region.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this_local_to_this_per" {
  provider = aws.peer

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id
  tags = {
    Name = format(local.peering_name_format, local.local_super_router_name, local.peer_super_router_name)
    Side = "Peer Accepter"
  }
}

########################################################################################
# Begin Super Router Local Side
########################################################################################

########################################################################################
# Begin Super Router Peer Side
########################################################################################

########################################################################################
# Begin Centralized Router Local Side
########################################################################################

########################################################################################
# Begin Centralized Router Peer Side
########################################################################################
