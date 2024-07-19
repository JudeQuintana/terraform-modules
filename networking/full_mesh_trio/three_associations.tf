resource "aws_ec2_transit_gateway_route_table_association" "this_three_to_this_one" {
  provider = aws.three

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_three_to_this_two" {
  provider = aws.three

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}
