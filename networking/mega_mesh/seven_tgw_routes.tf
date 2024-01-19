# seven
resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.seven

  for_each = local.one_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.seven

  for_each = local.two_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.seven

  for_each = local.three_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_four_tgw" {
  provider = aws.seven

  for_each = local.four_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_four.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_five_tgw" {
  provider = aws.seven

  for_each = local.five_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_five.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_six_tgw" {
  provider = aws.seven

  for_each = local.six_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_six.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_eight_tgw" {
  provider = aws.seven

  for_each = local.eight_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_seven.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_nine_tgw" {
  provider = aws.seven

  for_each = local.nine_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_seven.id
}

resource "aws_ec2_transit_gateway_route" "this_seven_tgw_routes_to_vpcs_in_ten_tgw" {
  provider = aws.seven

  for_each = local.ten_tgw_vpc_network_cidrs

  transit_gateway_route_table_id = local.seven_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_seven.id
}

