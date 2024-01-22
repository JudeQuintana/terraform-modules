# eight
resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_one" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_two" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_three" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_three.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_four" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_five" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_five.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_six" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_six.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_seven" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_seven.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_nine" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_eight.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_eight_to_this_ten" {
  provider = aws.eight

  transit_gateway_route_table_id = local.eight_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_eight.id
}

