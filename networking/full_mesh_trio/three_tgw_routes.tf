resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.three

  for_each = local.one_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.three

  for_each = local.two_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

#ipv6
resource "aws_ec2_transit_gateway_route" "this_three_tgw_ipv6_routes_to_vpcs_in_one_tgw" {
  provider = aws.three

  for_each = local.one_tgw_vpc_ipv6_network_cidrs

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_ipv6_routes_to_vpcs_in_two_tgw" {
  provider = aws.three

  for_each = local.two_tgw_vpc_ipv6_network_cidrs

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}
