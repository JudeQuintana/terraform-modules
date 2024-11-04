output "peering" {
  value = {
    one = {
      attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
      from          = local.one_tgw.full_name
      to            = local.two_tgw.full_name
    }
    two = {
      attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
      from          = local.two_tgw.full_name
      to            = local.three_tgw.full_name
    }
    three = {
      attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
      from          = local.three_tgw.full_name
      to            = local.one_tgw.full_name
    }
  }
}

