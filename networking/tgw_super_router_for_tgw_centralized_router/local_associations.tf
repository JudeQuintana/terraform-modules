# associate all local tgw routes table to local tgw super router route tables
resource "aws_ec2_transit_gateway_route_table_association" "this_local" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment.this_local_to_locals, each.key).id

  # make sure the peer links are up before adding the route table association.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals]
}

# associate local tgw route table to local attachment accepters
resource "aws_ec2_transit_gateway_route_table_association" "this_local_to_locals" {
  provider = aws.local

  for_each = local.local_tgw_id_to_local_tgw

  transit_gateway_route_table_id = each.value.route_table_id
  transit_gateway_attachment_id  = lookup(aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_locals, each.key).id

  lifecycle {
    ignore_changes = [transit_gateway_attachment_id]
  }
}

# You cannot propagate a tgw peering attachment to a Transit Gateway Route Table
# resource "aws_ec2_transit_gateway_route_table_propagation" "this_local" {}

# associate local tgw route table to super router peering attachment
resource "aws_ec2_transit_gateway_route_table_association" "this_local_to_this_peer" {
  provider = aws.local

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this_local.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this_local_to_this_peer.id

  # make sure the peer links are up before associating the route the route.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this_local_to_this_peer]
}
