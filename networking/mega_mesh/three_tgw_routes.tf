# three
resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.three

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.three

  for_each = toset(local.two_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_four_tgw" {
  provider = aws.three

  for_each = toset(local.four_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_five_tgw" {
  provider = aws.three

  for_each = toset(local.five_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_six_tgw" {
  provider = aws.three

  for_each = toset(local.six_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_three_tgw_routes_to_vpcs_in_seven_tgw" {
  provider = aws.three

  for_each = toset(local.seven_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.three_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_three.id
}

