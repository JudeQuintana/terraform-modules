# nine
resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_one" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_one.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_two" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_two.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_three" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_three.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_four" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_four.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_five" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_five.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_six" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_six.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_seven" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_seven.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_eight" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_eight.id
}

resource "aws_ec2_transit_gateway_route_table_association" "this_nine_to_this_ten" {
  provider = aws.nine

  transit_gateway_route_table_id = local.nine_tgw.route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_nine.id
}

