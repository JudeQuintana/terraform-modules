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

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_six" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_five.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_seven" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_five.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_eight" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_five.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_nine" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_five.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_five_to_this_ten" {
  provider = aws.five

  transit_gateway_route_table_id = local.five_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_five.id
}
