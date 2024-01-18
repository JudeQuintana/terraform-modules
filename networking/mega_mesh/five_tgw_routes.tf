# five
resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.five

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.five

  for_each = toset(local.two_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.five

  for_each = toset(local.three_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_four_tgw" {
  provider = aws.five

  for_each = toset(local.four_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_four.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_six_tgw" {
  provider = aws.five

  for_each = toset(local.six_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_five.id
}

resource "aws_ec2_transit_gateway_route" "this_five_tgw_routes_to_vpcs_in_seven_tgw" {
  provider = aws.five

  for_each = toset(local.seven_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_five.id
}

