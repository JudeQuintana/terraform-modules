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

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_five" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_six" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_seven" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_eight" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_nine" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_four_to_this_ten" {
  provider = aws.four

  transit_gateway_route_table_id = local.four_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_four.id
}

