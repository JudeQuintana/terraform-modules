# six
resource "aws_ec2_transit_gateway_route" "this_six_tgw_routes_to_vpcs_in_one_tgw" {
  provider = aws.six

  for_each = toset(local.one_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_one.id
}

resource "aws_ec2_transit_gateway_route" "this_six_tgw_routes_to_vpcs_in_two_tgw" {
  provider = aws.six

  for_each = toset(local.two_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_two.id
}

resource "aws_ec2_transit_gateway_route" "this_six_tgw_routes_to_vpcs_in_three_tgw" {
  provider = aws.six

  for_each = toset(local.three_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_three.id
}

resource "aws_ec2_transit_gateway_route" "this_six_tgw_routes_to_vpcs_in_four_tgw" {
  provider = aws.six

  for_each = toset(local.four_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_four.id
}

resource "aws_ec2_transit_gateway_route" "this_six_tgw_routes_to_vpcs_in_five_tgw" {
  provider = aws.six

  for_each = toset(local.five_tgw_vpc_network_cidrs)

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_five.id
}

## Associations
# four
resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_one" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_two" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_three" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_three.id
}

# five
resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_one" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_two" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_three" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_three.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_four" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_four.id
}

# six
resource "aws_ec2_transit_gateway_route_table_association" "this_six_to_this_one" {
  provider = aws.six

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_six_to_this_two" {
  provider = aws.six

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_six_to_this_three" {
  provider = aws.six

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_three.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_six_to_this_four" {
  provider = aws.six

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_six_to_this_five" {
  provider = aws.six

  transit_gateway_route_table_id = local.six_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_five.id
}
