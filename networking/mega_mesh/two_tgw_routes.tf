# two
resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.two

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.two

  for_each = toset(local.three_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
}


resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_four_tgw" {
  provider = aws.two

  for_each = toset(local.four_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_five_tgw" {
  provider = aws.two

  for_each = toset(local.five_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_two_tgw_routes_to_vpcs_in_six_tgw" {
  provider = aws.two

  for_each = toset(local.six_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.two_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_two.id
}
