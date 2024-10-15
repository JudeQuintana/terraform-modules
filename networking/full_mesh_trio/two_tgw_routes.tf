resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.two

  for_each = local.one_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.two

  for_each = local.three_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

#ipv6
resource "aws_ec2_transit_gateway_route" "this_two_tgw_ipv6_routes_to_vpcs_in_one_tgw" {
  provider = aws.two

  for_each = local.one_tgw_vpc_ipv6_network_cidrs

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_two_tgw_ipv6_routes_to_vpcs_in_three_tgw" {
  provider = aws.two

  for_each = local.three_tgw_vpc_ipv6_network_cidrs

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}
