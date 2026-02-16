# associate all peer tgw routes table to peer tgw super router route table
resource "aws_ec2_transit_gateway_route_table_association" "this_peer" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_peer_to_peers, each.key).id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers]
}

# associate peer tgw route table to peer attachment accepters
resource "aws_ec2_transit_gateway_route_table_association" "this_peer_to_peers" {
  provider = aws.peer

  for_each = local.peer_tgw_id_to_peer_tgw

  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_peer_to_peers, each.key).id

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

# You cannot propagate a tgw peering attachment to a Transit Gateway Route Table
# resource "aws_ec2_transit_gateway_route_table_propagation" "this_peer" {}

# associate peer tgw route table to super router peering attachment
resource "aws_ec2_transit_gateway_route_table_association" "this_peer_to_this_local" {
  provider = aws.peer

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_peer.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before associating the route the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}
